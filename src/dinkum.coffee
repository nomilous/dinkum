{client} = require './client/client'

exports.Client = 

    create: (config = {}) -> 

        config.transport       ||= 'https'
        config.hostname        ||= 'localhost'
        config.queueLimit       ?= 100
        config.rateLimit        ?= 10
        config.connectTimeout  ||= 0
        config.allowUncertified ?= false
        
        client config


    # CookieStore: require './client/cookie_store'
    # BasicAuth:   require './client/basic_auth'


exports.Test = require './test'
