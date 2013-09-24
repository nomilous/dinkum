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
        type: undefined
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


            try authenticator.type = authenticator.scheme.type

            authenticator.scheme?


        configured: ->

            config.authenticator? and authenticator.assign()


        requestAuth: (httpRequest) -> 

            try 

                authenticator.scheme.requestAuth httpRequest
                return true

            catch error

                try error.detail = request: httpRequest.opts
                httpRequest.promised.reject error
                return false



        sessionAuth: deferred (action, httpRequest) -> 

            {resolve, reject, notify} = action

            unless authenticator.configured()

                error = new Error 'dinkum absence of authenticator scheme'
                error.detail = request: httpRequest.opts

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
                # * create an authentication request via authentication schema
                #

                queue.suspend = true
                authenticator.authenticating = httpRequest.sequence
                authenticator.scheme.sessionAuth action, httpRequest

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

                if httpRequest.authenticator? 

                    # 
                    # * this new 401 is in response to the authentication attempt
                    #   itself, the authentication has failed
                    # 

                    authenticator.authenticating = 0
                    authenticator.scheme.sessionAuth action, httpRequest

                    #
                    # TODO: reject the entire queue (clean up)
                    #

                    return

                queue.requeue( httpRequest ).then resolve, reject, notify


    authenticator.assign() if config.authenticator?
            
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator


    return api = 

        sessionAuth: authenticator.sessionAuth
        requestAuth:  authenticator.requestAuth
        type:        authenticator.type

