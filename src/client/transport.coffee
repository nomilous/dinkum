{promised} = require '../support'

transport = undefined
exports.testable = -> transport

exports.transport = (config = {}) -> 

    config.transport ||= 'https'

    if config.transport == 'https' 

        options = require('https').globalAgent.options
        options.rejectUnauthorized = not config.allowUncertified
        
    
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

            
            request = require( config.transport ).request requestOpts

            request.on 'error', (error) -> 

                if error.message == 'DEPTH_ZERO_SELF_SIGNED_CERT'

                    error = new Error( 

                        'dinkum encounter with uncertified server (use allowUncertified to trust it)'

                    )

                    error.detail = config.hostname
                    result.reject error
                    action.reject()
                    return


    return api = 

        request: transport.request
