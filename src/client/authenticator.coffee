{deferred} = require '../support'

testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config, queue) -> 

    authenticator = 

        queue: queue

        authenticating: false

        authenticate: -> 

            authenticator.authenticating = true
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
