{deferred} = require '../support'

transport = undefined
exports.testable = -> transport

exports.Transport = (config, queue) -> 

    if config.transport == 'https' 

        options = require('https').globalAgent.options
        options.rejectUnauthorized = not config.allowUncertified
    
    transport = 
        
        queue: queue

        request: deferred (action, httpRequest) -> 

            #
            # * request has local promise (action) to allow for re reposting 
            #   on authentication failure without affecting the the thefinal 
            #   result promise (httpRequest.promised)
            # 

            {opts, promised, sequence} = httpRequest

            requestOpts = {}

            requestOpts.port     = config.port if config.port?
            requestOpts.hostname = config.hostname
            
            requestOpts.method   = opts.method
            requestOpts.path     = opts.path



            httpRequest.state = 'create'
            request = require( config.transport ).request requestOpts, (response) -> 

                httpRequest.state = 'response'
                resultObj = 
                    statusCode: response.statusCode
                    headers:    response.headers
                    body:       ''


                response.on 'data', (chunk) -> 

                    #
                    # TODO: 
                    # - options of content type
                    # - options for large multiparts out via notify
                    # - progress ( content-length - accumulated chunk sum )
                    #

                    httpRequest.state = 'receive'
                    resultObj.body += chunk.toString()

                response.on 'error', (error) -> 

                    #
                    # #ERROR  dunno when / if this ever happens
                    # #DONE
                    # 

                    console.log UNHANDLED_ERROR: error


                response.on 'end', -> 

                    # 
                    # * completed / closed inbound socket 
                    # 

                    httpRequest.state = 'done'  #DONE
                    promised.resolve resultObj
                    action.resolve()


            request.on 'socket', (socket) -> 

                unless config.connectTimeout == 0
                    socket.setTimeout config.connectTimeout
                    socket.on 'timeout', -> 
                        request.abort()
                        msg = 'dinkum connect timeout'
                        error = new Error msg
                        error.detail = requestOpts

                        #
                        # errors set state to 'done'
                        # --------------------------
                        # 
                        # Pending retry ability later...
                        #

                        httpRequest.state = 'done'   #ERROR #DONE
                        httpRequest.error = error
                        promised.reject error
                        action.reject()

            request.on 'error', (error) -> 

                if error.message == 'DEPTH_ZERO_SELF_SIGNED_CERT'
                    msg = 'dinkum encounter with uncertified server' 
                    msg += ' (use allowUncertified to trust it)'
                    error = new Error msg
                    error.detail = requestOpts
                    httpRequest.state = 'done'   #ERROR #DONE
                    httpRequest.error = error
                    promised.reject error
                    action.reject()
                    return

                #
                # ASSUMPTION: all request errors mean there will be no 
                #             usable response from the server
                #

                error.detail = requestOpts
                promised.reject error
                action.reject()


            request.end()
            httpRequest.state = 'sent'


    return api = 

        request: transport.request
