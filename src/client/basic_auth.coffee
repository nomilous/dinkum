https       = require 'https'
{defer}     = require 'when' 
CookieStore = require './cookie_store'

exports.create = (config) -> 

    throw new Error(

        'BasicAuth.create(config) requires config.username, config.password, config.hostname'

    ) unless (

        config? and 
        config.username? and
        config.password? and 
        config.hostname?

    )

    config.port         ||= 443
    config.rateLimit        ?= 10   # limit concurrent requests (overflow is queued)
    # config.queueLimit   ||= 10   # limit size of queue (overflow or pending auth)
    #config.dequeueLimit ||= 10   # limit concurrent dequeue
    
    queued = {}
    active = {}
    done   = total: 0

    authenticating = 0
    sequence       = 1

    session = 

        cookies: CookieStore.create hostname: config.username

        get: (opts = {}, promise = defer()) -> 

            #
            # Assign sequence to each promise
            # 

            promise.sequence ||= ++sequence
                                    #
                                    # TODO: what happens at MAX_INT in javascript
                                    #       or is there even such a thing?
                                    #

            unless promise.sequence == authenticating

                #
                # cannot queue the authentication attempt
                #

                #
                # TODO: reject at queueLimit
                # 

                if authenticating

                    #
                    # all new requests while authenticating are queued
                    # 

                    queued[promise.sequence.toString()] = 
                    
                        statusAt:  Date.now()
                        status:    'pending auth'
                        promise:   promise
                        opts:      opts

                    return promise.promise


                if session.active >= config.rateLimit

                    #
                    # all new request that overflow rateLimit 
                    #

                    queued[promise.sequence.toString()] = 
                    
                        statusAt:  Date.now()
                        status:    'rate limit'
                        promise:   promise
                        opts:      opts

                    return promise.promise




            opts.method    = 'GET'
            opts.path    ||= '/'
            opts.headers ||=  {}

            cookie = session.cookies.getCookie()
            opts.headers.cookie = cookie if cookie?

            request = https.request 

                hostname: config.hostname
                port:     config.port
                path:     opts.path
                auth:     if authenticating == promise.sequence then opts.auth
                method:   opts.method
                headers:  opts.headers

                # 
                # TODO: some servers may have no notion of session at all, the auth
                #       header will then need to be sent on every request
                # 
                # TODO: in some cases it may be necessary to not send any cookies on
                #       the request carrying the authentication payload 
                # 
                #       eg. a peculiarly implemented server might not like to 
                #           authorize a session it has already rejected 
                # 
                # TODO: include node/dinkum in agent string
                #

                (response) -> 

                    if track = active[promise.sequence.toString()]
                        track.status   = 'connected'
                        track.statusAt = Date.now()
                        #
                        # TODO: finish/test states...
                        #


                    if response.statusCode == 401 # TODO: other statii of similar meaning

                        #
                        # A server says, "Authenticate please!"
                        #

                        if authenticating

                            #
                            # Client says, "But I just did. :("...
                            #

                            if authenticating == promise.sequence

                                #
                                # ...and this is the request that was sent with the
                                #    auth header
                                #
                                
                                authenticating = 0
                                promise.reject new Error 'Authentication Failed'
                                return
                                

                                #
                                # TODO: reject all on the pending auth queue
                                #

                            else 

                                #
                                # ...and this is a request that was sent before the server
                                #    responded to the first request with a 401
                                #

                                #
                                # TODO: reject at queueLimit
                                # 

                                queued[promise.sequence.toString()] = 
                                    status:    'pending auth'
                                    statusAt:  Date.now()
                                    promise:   promise
                                    opts:      opts

                                    
                                return

                        #
                        # Mark which of the promise sequence numbers is carrying the 
                        # auth attempt and recurse the request with the same promise, 
                        # this time including credentials into the auth header.
                        # 
                        # NOTE: node.https module does the encrypt on the creds.
                        # 

                        authenticating = promise.sequence
                        opts.auth = "#{config.username}:#{config.password}"
                        session.get opts, promise

                    else 

                        #
                        # not 401, set authentication to done
                        # 
                        # IMPORTANT: server may have resources that do not require
                        #            authentication, so it is possible that a request
                        #            will pass through here without the 401 even while
                        #            the other request is still pending authorization
                        # 
                        #            so this MUST ONLY set authentication to done if
                        #            `this` promise is the one carrying the auth attempt
                        #


                        #
                        # TODO: this should dequeue if not currently authentication
                        # TODO: what if the authorization request never returs?? 
                        # 
                        
                        if promise.sequence == authenticating 

                            authenticating = 0

                            for seq of queued
                                dqueue = queued[seq]
                                delete queued[seq]
                                if session.active >= config.rateLimit

                                    #
                                    # too many active
                                    #

                                    break

                                session.get dqueue.opts, dqueue.promise
                                






                    response.on 'end', -> 

                        done.total++
                        delete active[promise.sequence.toString()]
                        promise.resolve {}
                  


            active[promise.sequence.toString()] = 
                status:    'sent'
                statusAt:  Date.now()
                promise:   promise
                opts:      opts


            #
            # TODO: timeout (data timeout vs. connect timeout)
            #       perhaps also queue these
            # 
            # request.on 'socket', (socket) -> 
            #    socket.setTimeout config.timeout
            #    socket.on 'timeout', -> request.abort()  
            # 
            # 

            return promise.promise



        queued: {}
        active: {}

        status: -> 

            pended = count: 0, requests: {}
            sended = count: 0, requests: {}
            now    = Date.now()

            for seq of queued
                do (seq) -> 
                    pended.count++
                    pended.requests[seq] =
                        status:    queued[seq].status
                        statusAge: now - queued[seq].statusAt
                        path:      queued[seq].opts.path

                #
                # TODO: capacity to cancel queued requests
                #

            for seq of active
                do (seq) -> 
                    sended.count++
                    sended.requests[seq] =
                        status:    active[seq].status
                        statusAge: now - active[seq].statusAt
                        path:      active[seq].opts.path

                        

            return queued: pended, active: sended, done: done


    Object.defineProperty session, 'queued', 
        enumarable: true
        get: ->  
            count = 0 
            count++ for seq of queued
            count

    Object.defineProperty session, 'active', 
        enumarable: true
        get: ->  
            count = 0 
            count++ for seq of active
            count


