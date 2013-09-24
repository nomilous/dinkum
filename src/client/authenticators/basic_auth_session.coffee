module.exports = (config) ->

    basicAuth =

        type: 'session'

        originalRequest: undefined

        failedAuth: (action) -> 

            error = new Error 'dinkum session authentication failure'
            try error.detail = basicAuth.originalRequest.opts
            basicAuth.originalRequest.promised.reject error
            basicAuth.originalRequest = undefined
            action.reject()


        sessionAuth: (action, forbiddenRequest) -> 

            if forbiddenRequest.authenticator == 'basic_auth'

                #
                # forbiddenRequest has already been marked
                # ----------------------------------------
                # 
                # * This request WAS the authentication attempt
                # * Still got 401
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

