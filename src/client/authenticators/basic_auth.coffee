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

        requestAuth: (httpRequestOpts) -> 

            username = config.authenticator.username
            password = config.authenticator.password
            httpRequestOpts.auth = "#{username}:#{password}"
