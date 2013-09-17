{promised} = require '../support'

transport = undefined
exports.testable = -> transport

exports.transport = (config = {}) -> 

    config.transport ||= 'https'
    
    transport = 

        request: promised (action, opts = {}, result) -> 

            #
            # * request has local promise to allow for reposting
            #   on authentication failure without affecting the
            #   the final result promise
            #

            requestOpts = {}
            
            requestOpts.port     = config.port if config.port?
            requestOpts.hostname = config.hostname
            
            requestOpts.method   = opts.method
            requestOpts.path     = opts.path

            require( config.transport ).request requestOpts


    return api = 

        request: transport.request
