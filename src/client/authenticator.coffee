testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config, queue) -> 

    authenticator = 

        queue: queue
        
        authenticate: -> 
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
