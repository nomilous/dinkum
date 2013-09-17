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



    it 'can send an http request', (done) -> 
 
        http.request = -> done(); on: ->
        instance = transport transport: 'http'
        instance.request()

    it 'can send an https request', (done) -> 

        https.request = -> done(); on: ->
        instance = transport transport: 'https'
        instance.request()


    it 'assigns hostname, port from config', (done) -> 

        https.request = (opts) -> 
            opts.hostname.should.equal 'localhost'
            opts.port.should.equal 3000
            done()
            on: ->

        instance = transport port: 3000, hostname: 'localhost'
        instance.request()


    it 'assigns method, path from opts', (done) -> 

        instance = transport port: 3000, hostname: 'localhost'
        https.request = (opts) -> 
            opts.method.should.equal 'GET'
            opts.path.should.equal '/'
            done()
            on: ->

        instance.request method: 'GET', path: '/'


    it 'suggests how to deal with DEPTH_ZERO_SELF_SIGNED_CERT', (done) -> 

        https.request = -> on: (event, listener) -> if event == 'error'

            listener new Error 'DEPTH_ZERO_SELF_SIGNED_CERT'


        instance = transport port: 3000, hostname: 'localhost'
        instance.request { method: 'GET', path: '/' }, reject: (error) -> 

            error.should.match /use allowUncertified to trust it/
            done()
