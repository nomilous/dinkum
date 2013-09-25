{enclose, deferred} = require 'also'
{Authenticator}     = require './authenticator'

testable = undefined
exports._transport = -> testable

exports.Transport = enclose Authenticator, (authenticator, config, queue, cookies) -> 

    if config.transport == 'https' 

        options = require('https').globalAgent.options
        options.rejectUnauthorized = not config.allowUncertified
    
    transport = 

        #
        # testable
        #

        queue: queue
        authenticator: authenticator
        cookies: cookies

        request: deferred (action, httpRequest) -> 

            #
            # * request has local promise (action) to allow for re reposting 
            #   on authentication failure without affecting the the thefinal 
            #   result promise (httpRequest.promised)
            # 

            {resolve, reject, notify}  = action
            {opts, promised, sequence} = httpRequest

            requestOpts          = {}
            requestOpts.port     = config.port if config.port?
            requestOpts.hostname = config.hostname
            requestOpts.method   = opts.method
            requestOpts.path     = opts.path
            requestOpts.auth     = opts.auth if opts.auth

            if cookie = cookies.getCookie()
                
                requestOpts.headers ||= {}
                requestOpts.headers.cookie = cookie

            if authenticator.type == 'request'
                unless authenticator.requestAuth requestOpts

                    #
                    # authenticator.scheme is of type=request but did not
                    # implement the requestAuth() method
                    # 

                    reject()
                    return


            httpRequest.state = 'create'
            request = require( config.transport ).request requestOpts, (response) -> 

                if response.headers['set-cookie']?
                    cookies.setCookie response.headers['set-cookie']


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

                        unless transport.authenticator.type == 'session'

                            #
                            # * only authentication schema of type=session will attempt 
                            #   an authentication after a 401
                            # 
                            # * all other types perfom the authentication inline before
                            #   each request, for those a 401 means authentication has
                            #   automatically failed
                            #

                            reject()
                            error = new Error 'dinkum authentication failure (request)'
                            error.detail = 
                                request:  requestOpts
                                response: resultObj

                            httpRequest.promised.reject error
                            return
                            

                        httpRequest.state = 'authenticating'
                        transport.authenticator.startSessionAuth( httpRequest ).then(

                            (authRequest) ->

                                if authRequest? 

                                    #
                                    # * authenticator only generates an authRequest if one 
                                    #   should be sent, on multiple concurrent 401s it will
                                    #   generate only on the first
                                    # 

                                    transport.request( authRequest ).then resolve, reject, notify 

                            reject
                            notify

                        )
                                
                        

                    else

                        finish = -> 

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

                        
                        if httpRequest.authenticator?

                            #
                            # * this request was an authenticator, the auth is finished
                            #
                            
                            transport.authenticator.endSessionAuth( httpRequest, resultObj ).then( 
                                
                                ->  
                                    #
                                    # TODO: the absence of a 401 in response to an authentication
                                    #       does not necessarilly mean that the authentication has
                                    #       succeeded (FIX)
                                    #

                                    queue.suspend = false

                                    #
                                    # TODO: future auth modules will manipulate the queue directly
                                    #       or send a sequence of requests to perform the auth,
                                    # 
                                    #       this call to finish() assumes that the current request
                                    #       in resultObj is the original request that required the
                                    #       authentication, it is resolved into the external callers
                                    #       request promise (FIX)
                                    #

                                    finish()

                                reject
                                notify

                            )
                            return

                        finish()
                            



            request.on 'socket', (socket) -> 

                unless config.connectTimeout == 0
                    socket.setTimeout config.connectTimeout
                    socket.on 'timeout', -> 
                        request.abort()
                        msg = 'dinkum connect timeout'
                        error = new Error msg
                        error.detail = request: requestOpts

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
                    error.detail = request: requestOpts
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

                error.detail = request: requestOpts
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
