{deferred}    = require '../support'
HttpRequest = require './http_request' 

testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config, queue) -> 

    authenticator = 

        queue: queue

        authenticating: false

        authenticate: deferred (action) -> 

            authenticator.authenticating = true
            action.resolve new HttpRequest
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
