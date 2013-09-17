{promised} = require '../support'

transport = undefined
exports.testable = -> transport

exports.transport = (config = {}) -> 
    
    transport = 

        request: promised (action, opts = {}, result) -> 

            #
            # * request has local promise to allow for reposting
            #   on authentication failure without affecting the
            #   the final result promise
            #

            require( config.transport ).request opts


    return api = 

        request: transport.request
