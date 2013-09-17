{testable, transport} = require '../../lib/client/transport'
http      = require 'http'
https     = require 'https'
should    = require 'should'

describe 'transport', -> 

    it 'can send an http request', (done) -> 

        swap = http.request
        http.request = -> 
            http.request = swap
            done()

        instance = transport transport: 'http'
        instance.request()

    it 'can send an https request', (done) -> 

        swap = https.request
        https.request = -> 
            https.request = swap
            done()

        instance = transport transport: 'https'
        instance.request()





