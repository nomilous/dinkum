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

    config.port  ||= 443
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

            opts.method    = 'GET'
            opts.path      = '/'
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
                                # ...and this is a request that was sent while waiting
                                #    for a response to the authentication request that
                                #    that was sent after the first 401
                                # 
                                # TODO: These subsequent requests should more sensibly 
                                #       be intercepted earlier. 
                                #       They should not be posted
                                #

                                return

                        #
                        # Mark the promise carrying the auth request and 
                        # set the same mark (sequence number) as the 
                        # authentication in progress flag
                        # 

                        opts.auth = "#{config.username}:#{config.password}"
                        authenticating = promise.sequence
                        session.get opts, promise
                        return

                    else 

                        #
                        # not 401, set authentication to done
                        # 
                        # IMPORTANT: server may have resources that to not require
                        #            authentication, so it is possible that a request
                        #            will pass through here without the 401 even while
                        #            the other request is still pending authorization
                        # 
                        #            so this MUST ONLY set authentication to done if
                        #            the promise is the one carrying the auth attempt
                        #

                        if promise.sequence == authenticating 

                            authenticating = 0

                            #
                            # TODO: release the pending auth queue
                            #


                    response.on 'end', -> 


                        promise.resolve {}
                    


            return promise.promise

