#
# BasicAuthSession
# ================
# 
# For API servers that require a once-off BASIC authentication
# and provide a resulting session context using cookies. 
#

module.exports = (config, queue, cookies) ->

    basicAuth =

        type: 'session'

        originalRequest: undefined

        failedAuth: (action) -> 

            error = new Error 'dinkum authentication failure (session)'
            try error.detail = basicAuth.originalRequest.opts
            basicAuth.originalRequest.promised.reject error
            basicAuth.originalRequest = undefined
            action.reject()


        startSessionAuth: (action, forbiddenRequest) -> 

            if forbiddenRequest.authenticator? #  == 'basic_auth_session'

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
            authRequest.authenticator = 'basic_auth_session'

            username = config.authenticator.username
            password = config.authenticator.password
            authRequest.opts.auth = "#{username}:#{password}"

            action.resolve authRequest


        endSessionAuth: (action, authRequest, authResponse) -> 

            action.resolve()
