testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config) -> 

    authenticator = 

        authenticate: -> 
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
