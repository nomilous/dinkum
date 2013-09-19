should      = require 'should'
HttpRequest = require '../../lib/client/http_request'

describe 'HttpRequest', -> 
    
    beforeEach -> 

        @now = Date.now

    afterEach -> 

        Date.now = @now


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

        Date.now = -> 1
        r = new HttpRequest 'PROMISED', path: '/'
        r.state.should.equal 'pending'
        r.stateAt.should.equal 1
        done()

    it 'has stateAt updated when state is updated', (done) ->

        Date.now = -> 12345
        r = new HttpRequest 'PROMISED', path: '/'
        r.state = 'request'
        r.stateAt.should.equal 12345
        r.state.should.equal 'request'

        done()
