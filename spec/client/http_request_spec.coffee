should      = require 'should'
HttpRequest = require '../../lib/client/http_request'

describe 'HttpRequest', -> 

    it 'is assigned a sequence number', (done) -> 

        r = new HttpRequest {}, path: '/'
        r.sequence.should.equal 1
        done()

    it 'stores the request opts', (done) -> 

        r = new HttpRequest {}, path: '/'
        r.opts.path.should.equal '/'
        done()

    it 'stores the request deferral', (done) -> 

        r = new HttpRequest 'PROMISED', path: '/'
        r.deferral.should.equal 'PROMISED'
        done()

