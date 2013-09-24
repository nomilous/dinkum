{deferred} = require '../support'
HttpRequest = require './http_request'
 
testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config, queue) -> 

    config ||= {}

    authenticator = 

        queue: queue

        authenticating: 0

        #
        # authentication scheme
        # ---------------------
        # 

        scheme: undefined 
        assign: -> 

            return false unless config.authenticator.module?
            return true if authenticator.scheme?

            try

                #
                # * first attempt node_module (plugin) as authenticator scheme
                # 
                #    TODO: Not entirely certain this will load the node module
                #          from the correct node_modules directory.
                #

                modulePath = "#{ config.authenticator.module }"
                authenticator.scheme = require( modulePath ) config

            catch error

                try

                    #
                    # * fall back to local authenticators
                    #

                    modulePath = "./authenticators/#{ config.authenticator.module }"
                    authenticator.scheme = require( modulePath ) config

            authenticator.scheme?

        configured: ->

            config.authenticator? and authenticator.assign()

        authenticate: deferred (action, httpRequest) -> 

            unless authenticator.configured()

                error = new Error 'dinkum absence of authenticator scheme'
                error.detail = httpRequest.opts
                httpRequest.promised.reject error
                action.reject()
                return

            authenticator.authenticating = httpRequest.sequence
            action.resolve new HttpRequest
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
