module.exports = (config) ->

    basicAuth =

        type: 'session'

        originalRequest: undefined

        failedAuth: (action) -> 

            basicAuth.originalRequest.reject new Error 'Authentication Failed'
            basicAuth.originalRequest = undefined
            action.reject()


        startAuth: (action, forbiddenRequest) -> 

            if forbiddenRequest.authenticator == 'basic_auth'

                #
                # forbidden request is the authentication attempt
                # -----------------------------------------------
                # 
                # * Authentication has failed
                #

                basicAuth.failedAuth action
                return

            #
            # create authentication request
            # -----------------------------
            # 
            # * it is marked to signify that this request is carriing
            #   the authentication attempt
            #

            basicAuth.originalRequest = forbiddenRequest
            authRequest = forbiddenRequest
            authRequest.authenticator = 'basic_auth'
            action.resolve authRequest

