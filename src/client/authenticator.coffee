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
            return true if authenticator.scheme? # already assigned

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

            {resolve, reject, notify} = action

            unless authenticator.configured()

                error = new Error 'dinkum absence of authenticator scheme'
                error.detail = httpRequest.opts

                #
                # * reject all the way to the response promise held by 
                #   the outside caller 
                #

                httpRequest.promised.reject error
                action.reject()
                return

            if authenticator.authenticating == 0

                #
                # new authentication attempt
                # --------------------------
                # 
                # * suspend the queue
                # TODO * create an authentication request via authentication schema
                #

                queue.suspend = true
                authenticator.authenticating = httpRequest.sequence
                action.resolve new HttpRequest

            else 

                #
                # authentication already in progress
                # ----------------------------------
                # 
                # * while authentication is in progress all requests to which
                #   the server responds with a 401 are requeued, this only
                #   occurs when multiple requests were sent in parallel before
                #   the authentication, the first request initiates the authcycle
                #   and all 401s that follow pass through here 
                #  

                queue.requeue( httpRequest ).then resolve, reject, notify
                newAuthRequest = null
                action.resolve newAuthRequest

            
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
