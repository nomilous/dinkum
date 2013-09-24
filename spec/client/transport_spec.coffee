{_transport, Transport} = require '../../lib/client/transport'
{Requestor} = require '../../lib/client/requestor'
{Test} = require '../../lib/dinkum'
{start, stop, server} = Test.HttpsServer
http      = require 'http'
https     = require 'https'
should    = require 'should'

httpr  = undefined
httpsr = undefined

describe 'Transport', -> 
    
    beforeEach -> 
        httpr  = http.request
        httpsr = https.request
        @mockQueue = update: -> then: (resolve) -> resolve()

    afterEach -> 
        http.request  = httpr
        https.request = httpsr

    context 'units', ->

        it 'can send an http request', (done) -> 
     
            http.request = -> 
                done()
                end: ->
                on: ->

            instance = Transport transport: 'http' 
            instance.request opts: {}, sequence: 1, promised: {}

        it 'can send an https request', (done) -> 

            https.request = -> 
                done()
                end: ->
                on: ->

            instance = Transport { transport: 'https' }, @mockQueue
            instance.request opts: {}, sequence: 2, promised: {}



        it 'assigns hostname, port from config', (done) -> 

            https.request = (opts) -> 
                opts.hostname.should.equal 'localhost'
                opts.port.should.equal 3000
                done()
                end: ->
                on: ->

            instance = Transport transport: 'https', port: 3000, hostname: 'localhost'
            instance.request opts: {}, promised: {}, sequence: 1


        it 'assigns method, path from opts', (done) -> 

            instance = Transport transport: 'https', port: 3000, hostname: 'localhost'
            https.request = (opts) -> 
                opts.method.should.equal 'GET'
                opts.path.should.equal '/'
                done()
                end: ->
                on: ->

            instance.request opts: { method: 'GET', path: '/', 1 }, promised: {}, sequence: 1


        it 'suggests how to deal with DEPTH_ZERO_SELF_SIGNED_CERT', (done) -> 

            https.request = -> 
                end: ->
                on: (event, listener) -> if event == 'error'
                    listener new Error 'DEPTH_ZERO_SELF_SIGNED_CERT'

            instance = Transport transport: 'https', port: 3000, hostname: 'localhost'
            instance.request opts: { method: 'GET', path: '/' }, sequence: 1, promised:
                reject: (error) -> 
                    error.should.match /use config.allowUncertified to trust it/
                    done()


        it 'can assign a connect timeout', (done) -> 

            ABORTED = false
            https.request = -> 
                abort: -> ABORTED = true
                end: ->
                on: (event, listener) -> 
                    if event == 'socket'
                        listener
                            setTimeout: (value) -> value.should.equal 20
                            on: (event, listener) -> if event == 'timeout' then listener()
                
            instance = Transport { transport: 'https', connectTimeout: 20 }, @mockQueue
            instance.request opts: { method: 'GET', path: '/' }, sequence: 1, promised: 
                reject: (error) -> 
                    error.should.match /dinkum connect timeout/
                    done()


        it 'sets no timeout if 0', (done) -> 

            https.request = -> 
                end: ->
                on: (event, listener) -> 
                    if event == 'socket'
                        listener
                            setTimeout: (value) -> 
                                throw 'should not set timeout'
                
            instance = Transport { transport: 'https', connectTimeout: 0 }, @mockQueue
            instance.request  opts: { method: 'GET', path: '/' }, sequence: 1, promised: {}
            done()


        it 'rejects on all request errors', (done) -> 

            https.request = -> 
                end: ->
                on: (event, listener) -> if event == 'error'
                    listener new Error "assumption"


            instance = Transport transport: 'https', port: 3000, hostname: 'localhost'
            instance.request opts: { method: 'GET', path: '/' }, sequence: 1, promised:
                reject: (error) -> 
                    error.should.match /assumption/
                    done()


        it 'accumulates body as string and resolves including header and status code', (done) ->

            instance = Transport { transport: 'https', port: 3000, hostname: 'localhost' }, @mockQueue
            https.request = (opts, callback) -> 
                callback
                    headers:    'HEADERS'
                    statusCode: 'STATUSCODE'
                    on: (event, listener) -> 
                        if event == 'data' 
                            listener new Buffer '<HTML>'
                            listener new Buffer '</HTML>'
                        if event == 'end' then listener()
                on: -> 
                end: ->

            instance.request opts: { method: 'GET', path: '/' }, sequence: 1, promised: 
                resolve: (result) -> 
                    result.should.eql 
                        statusCode: 'STATUSCODE'
                        headers:    'HEADERS'
                        body:       '<HTML></HTML>'

                    done()

    context 'integrations', ->

        before (done) -> start port: 3001, done
        after (done) -> stop done

        it 'is initialized with queue (by the Requestor)', (done) ->

            requestor = Requestor transport: 'https'
            should.exist _transport().queue
            done()


        it 'assigns httpRequest state as done on response end', (done) -> 

            server.log.on
            transport = Transport
                transport:  'https'
                allowUncertified: true
                port:       3001
                @mockQueue

            mockHttpRequest = 
                opts: path: '/', method: 'GET'
                promised:
                    resolve: (result) ->
                    reject: (error) -> 
                        console.log 
                            SPEC_ERROR_1: error
                            spec: __filename
                
            transport.request( mockHttpRequest ).then ->

                mockHttpRequest.state.should.equal 'done'
                done()


        it 'assigns httpRequest state as authenticate on response 401', (done) -> 

            server.log.off
            transport = Transport
                transport:  'https'
                allowUncertified: true
                port:       3001

            mockHttpRequest = 
                opts: path: '/', method: 'GET'
                promised:
                    resolve: (result) ->
                    reject: (error) -> 
                        console.log 
                            SPEC_ERROR_1: error
                            spec: __filename


            server.setResponse statusCode: 401
            transport.request( mockHttpRequest ).then ->

                mockHttpRequest.state.should.equal 'authenticate'
                done()



