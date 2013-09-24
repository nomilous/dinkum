{enclose, deferred} = require '../support'
{Authenticator}     = require './authenticator'

testable = undefined
exports._transport = -> testable

exports.Transport = enclose Authenticator, (authenticator, config, queue) -> 

    if config.transport == 'https' 

        options = require('https').globalAgent.options
        options.rejectUnauthorized = not config.allowUncertified
    
    transport = 

        #
        # testable
        #

        queue: queue
        authenticator: authenticator

        request: deferred (action, httpRequest) -> 

            #
            # * request has local promise (action) to allow for re reposting 
            #   on authentication failure without affecting the the thefinal 
            #   result promise (httpRequest.promised)
            # 

            {resolve, reject, notify}  = action
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

                    if resultObj.statusCode == 401

                        transport.authenticator.authenticate()
                        httpRequest.state = 'authenticate'
                        action.resolve()

                    else

                        httpRequest.state = 'done'  #DONE
                        queue.update( 'done', httpRequest ).then( 

                            -> 
                                #
                                # final resultObj resolves the promise that was made to 
                                # the external caller once the queue is updated 
                                #

                                resolve()
                                promised.resolve resultObj 

                            reject
                            notify

                        )


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
                        queue.update( 'done', httpRequest ).then( 
                            -> 
                                reject()
                                promised.reject error
                            reject
                            notify
                        )
                        

            request.on 'error', (error) -> 

                #
                # ASSUMPTION: all request errors mean there will be no 
                #             usable response from the server
                #

                if error.message == 'DEPTH_ZERO_SELF_SIGNED_CERT'
                    msg = 'dinkum encounter with uncertified server' 
                    msg += ' (use config.allowUncertified to trust it)'
                    error = new Error msg
                    error.detail = requestOpts
                    httpRequest.state = 'done'   #ERROR #DONE
                    httpRequest.error = error
                    queue.update( 'done', httpRequest ).then( 
                        -> 
                            reject()
                            promised.reject error
                        reject
                        notify
                    )
                    return

                error.detail = requestOpts
                queue.update( 'done', httpRequest ).then( 
                    -> 
                        reject()
                        promised.reject error
                    reject
                    notify
                )



            request.end()
            httpRequest.state = 'sent'

    #
    # only the latest instance is accessable to test
    #

    testable = transport

    return api = 

        request: transport.request
