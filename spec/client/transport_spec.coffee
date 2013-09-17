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
 
        http.request = -> done()
        instance = transport transport: 'http'
        instance.request()

    it 'can send an https request', (done) -> 

        https.request = -> done()
        instance = transport transport: 'https'
        instance.request()


    it 'assigns hostname, port from config', (done) -> 

        https.request = (opts) -> 
            opts.hostname.should.equal 'localhost'
            opts.port.should.equal 3000
            done()

        instance = transport port: 3000, hostname: 'localhost'
        instance.request()


    it 'assigns method, path from opts', (done) -> 

        instance = transport port: 3000, hostname: 'localhost'
        https.request = (opts) -> 
            opts.method.should.equal 'GET'
            opts.path.should.equal '/'
            done()

        instance.request method: 'GET', path: '/'

