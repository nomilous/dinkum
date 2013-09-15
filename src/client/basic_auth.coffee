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
    authenticating = false

    session = 

        cookies: CookieStore.create hostname: config.username

        get: (opts = {}, deferral = defer()) -> 

            opts.method    = 'GET'
            opts.path      = '/'
            opts.headers ||=  {}

            cookie = session.cookies.getCookie()
            opts.headers.cookie = cookie if cookie?

            request = https.request 

                hostname: config.hostname
                port:     config.port
                path:     opts.path
                auth:     opts.auth
                method:   opts.method
                headers:  opts.headers

                #
                # TODO: include node/dinkum in agent string
                #

                (response) -> 

                    if response.statusCode == 401

                        if authenticating

                            deferral.reject new Error 'Authentication Failed'
                            authenticating = false
                            return

                        opts.auth = "#{config.username}:#{config.password}"
                        authenticating = true
                        session.get opts, deferral
                        return
                    


            return deferral.promise

