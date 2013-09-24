#
# BasicAuth
# =========
# 
# For API servers that require BASIC authentication to be
# included with every request (no session context).
#
module.exports = (config) ->

    basicAuth =

        type: 'request'

        requestAuth: (httpRequest) -> 

            username = config.authenticator.username
            password = config.authenticator.password
            httpRequest.opts.auth = "#{username}:#{password}"
