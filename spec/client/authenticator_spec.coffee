{_authenticator, Authenticator} = require '../../lib/client/authenticator'
{Requestor} = require '../../lib/client/requestor'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'
sequence = require 'when/sequence'

describe 'Authenticator', ->

    before -> 
        @config = 
            authenticator: 
                module: 'basic_auth'

    beforeEach -> 
        @requeued = []
        @queue = 
            suspend: false
            requeue: (object) => 
                @requeued.push object
                then: (resolve, reject, notify) -> resolve()


    context 'first call to authenticate()', -> 


        it 'rejects the request promise if no authentication scheme is specified', (done) -> 

            instance = Authenticator()
            instance.authenticate promised: reject: (error) -> 

                error.should.match /dinkum absence of authenticator scheme/

                done()


        it 'assigns the authenticator scheme', (done) -> 

            instance = Authenticator @config, @queue
            instance.authenticate sequence: 1
            should.exist _authenticator().scheme
            done()

        it 'assigns the authenticator scheme only once', (done) ->

            instance = Authenticator @config, @queue
            instance.authenticate sequence: 1
            should.exist _authenticator().scheme
            _authenticator().scheme.TEST = 1

            instance.authenticate sequence: 1
            _authenticator().scheme.TEST.should.equal 1
            done()


        it 'can use node_module (plugin) as authenticator scheme'

        it 'sets authenticating to the sequence number of the first request', (done) -> 

            instance = Authenticator @config, @queue
            _authenticator().authenticating.should.equal 0
            instance.authenticate sequence: 1
            _authenticator().authenticating.should.equal 1
            done()


        it 'resolves with an authentication request', (done) ->

            instance = Authenticator @config, @queue
            instance.authenticate( sequence: 1 ).then (request) -> 

                request.should.be.an.instanceof HttpRequest
                done()


        it 'suspends the queue', (done) -> 

            instance = Authenticator @config, @queue
            instance.authenticate( sequence: 1 ).then (request) => 

                @queue.suspend.should.equal true
                done()

        it 'does not requeue the first request that requires authentication', (done) -> 

            instance = Authenticator @config, @queue
            instance.authenticate( sequence: 1 ).then (request) => 

                @requeued.should.eql []
                done()


    context 'subsequent calls to authenticate()', -> 

        #
        # a client that starts up with several requests in parallel
        # will receive several 401s if auth is required,
        # 
        # this authenticator directs only the first 401 through an
        # authentication sequence, subsequent requests are requeued
        # pending the authentication completion
        #

        it 'requeues request that require authentication while authentication is in progress', (done) -> 

            instance = Authenticator @config, @queue
            sequence([
                -> instance.authenticate sequence: 1
                -> instance.authenticate sequence: 2
                -> instance.authenticate sequence: 3

            ]).then => 

                @requeued.should.eql [
                    { sequence: 2 }
                    { sequence: 3 }
                ]
                done()


    context 'integrations', -> 

        it 'is assigned the queue via enclosed config-chain requestor..transport..', (done) -> 

            requestor = Requestor()
            should.exist _authenticator().queue
            done()

