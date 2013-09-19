{testable, transport} = require '../../lib/client/transport'
http      = require 'http'
https     = require 'https'
should    = require 'should'

httpr  = undefined
httpsr = undefined

describe 'transport', -> 
    
    beforeEach -> 
        httpr  = http.request
        httpsr = https.request

    afterEach -> 
        http.request  = httpr
        https.request = httpsr


    it.only 'can send an http request', (done) -> 
 
        http.request = -> 
            done()
            end: ->
            on: ->

        instance = transport transport: 'http'
        instance.request opts: {}, promised: {}, sequence: 1

    it 'can send an https request', (done) -> 

        https.request = -> 
            done()
            end: ->
            on: ->
        instance = transport transport: 'https'
        instance.request path: '/', 1


    it 'assigns hostname, port from config', (done) -> 

        https.request = (opts) -> 

            opts.hostname.should.equal 'localhost'
            opts.port.should.equal 3000
            done()
            end: ->
            on: ->

        instance = transport transport: 'https', port: 3000, hostname: 'localhost'
        instance.request path: '/', 1


    it 'assigns method, path from opts', (done) -> 

        instance = transport transport: 'https', port: 3000, hostname: 'localhost'
        https.request = (opts) -> 
            opts.method.should.equal 'GET'
            opts.path.should.equal '/'
            done()
            end: ->
            on: ->

        instance.request method: 'GET', path: '/', 1


    it 'suggests how to deal with DEPTH_ZERO_SELF_SIGNED_CERT', (done) -> 

        https.request = -> 
            end: ->
            on: (event, listener) -> if event == 'error'
                listener new Error 'DEPTH_ZERO_SELF_SIGNED_CERT'

        instance = transport transport: 'https', port: 3000, hostname: 'localhost'
        instance.request { method: 'GET', path: '/' }, 1, reject: (error) -> 

            error.should.match /use allowUncertified to trust it/
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
            
        instance = transport transport: 'https', connectTimeout: 20
        instance.request { method: 'GET', path: '/' }, 1, reject: (error) -> 

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
            
        instance = transport transport: 'https', connectTimeout: 0
        instance.request method: 'GET', path: '/'
        done()


    it 'rejects on all request errors', (done) -> 

        https.request = -> 
            end: ->
            on: (event, listener) -> if event == 'error'
                listener new Error "assumption"


        instance = transport transport: 'https', port: 3000, hostname: 'localhost'
        instance.request { method: 'GET', path: '/' }, 1, reject: (error) -> 

            error.should.match /assumption/
            done()


    it 'accumulates body as string and resolves including header and status code', (done) ->

        instance = transport transport: 'https', port: 3000, hostname: 'localhost'
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

        instance.request { method: 'GET', path: '/' }, 1, resolve: (result) -> 

                result.should.eql 
                    statusCode: 'STATUSCODE'
                    headers:    'HEADERS'
                    body:       '<HTML></HTML>'

                done()


