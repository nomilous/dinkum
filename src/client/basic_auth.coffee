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

    cookies = CookieStore.create config
    config.port ||= 443

    session = 

        get: (opts = {}, deferral = defer()) -> 

            opts.method = 'GET'
            opts.path   = '/'

            request = https.request 

                hostname: config.hostname
                port:     config.port
                path:     opts.path
                method:   opts.method
                headers:
                    cookie: cookies.getCookie()


            return deferral.promise

