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


            request.on 'socket', (socket) -> 

                unless config.connectTimeout == 0
                    socket.setTimeout config.connectTimeout
                    socket.on 'timeout', -> 
                        request.abort()
                        msg = 'dinkum connect timeout'
                        error = new Error msg
                        error.detail = requestOpts
                        result.reject error
                        action.reject()

            request.on 'error', (error) -> 

                if error.message == 'DEPTH_ZERO_SELF_SIGNED_CERT'
                    msg = 'dinkum encounter with uncertified server' 
                    msg += ' (use allowUncertified to trust it)'
                    error = new Error msg
                    error.detail = requestOpts
                    result.reject error
                    action.reject()
                    return

                #
                # ASSUMPTION: all request errors mean there will be no 
                #             usable response from the server
                #

                error.detail = requestOpts
                result.reject error
                action.reject()




    return api = 

        request: transport.request
