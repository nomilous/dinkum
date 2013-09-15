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
    #config.queueLimit   ||= 10   # limit size of pending queue (auth in progress)
    config.dequeueLimit ||= 10   # limit concurrent requests at dequeue
    queue                 = {}

    authenticating = 0
    sequence       = 0
    

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

            if authenticating and promise.sequence != authenticating

                #
                # NEW request while authentication is in progress, queue it
                # TODO: limit queue size 
                # 

                queue[promise.sequence.toString()] = opts: opts, promise: promise
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

                                queue[promise.sequence.toString()] = opts: opts, promise: promise
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

                        if promise.sequence == authenticating 

                            authenticating = 0
                            count = 1
                            for seq of queue
                                break if ++count > config.dequeueLimit
                                session.get queue[seq].opts, queue[seq].promise
                                delete queue[seq]

                            #
                            # TODO: what if the authorization request never returs??
                            # 

                    response.on 'end', -> 
                    
                        promise.resolve {}
                  
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

