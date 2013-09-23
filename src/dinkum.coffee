{Client} = require './client/client'

exports.Client = 

    create: (config = {}) -> 

        config.transport       ||= 'https'
        config.hostname        ||= 'localhost'
        config.queueLimit       ?= 100
        config.requestLimit     ?= 10
        config.connectTimeout  ||= 0
        config.allowUncertified ?= false
        
        return Client config

        #
        # rotate 'the chaos manifold'
        #

        ;


    # CookieStore: require './client/cookie_store'
    # BasicAuth:   require './client/basic_auth'


exports.Test = require './test'

exports.deferred = require './support/deferred'
