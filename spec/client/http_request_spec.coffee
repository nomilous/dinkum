should      = require 'should'
HttpRequest = require '../../lib/client/http_request'

describe 'HttpRequest', -> 

    it 'stores the request opts', (done) -> 

        r = new HttpRequest {}, path: '/'
        r.opts.path.should.equal '/'
        done()

    it 'stores the request deferral', (done) -> 

        r = new HttpRequest 'PROMISED', path: '/'
        r.promised.should.equal 'PROMISED'
        done()

    it 'can have sequence number assigned only once', (done) ->

        r = new HttpRequest 'PROMISED', path: '/'
        r.sequence = 1
        r.sequence = 2
        r.sequence.should.equal 1
        done()


    it 'has state initially pending', (done) -> 

        r = new HttpRequest 'PROMISED', path: '/'
        r.state.should.equal 'pending'
        done()

