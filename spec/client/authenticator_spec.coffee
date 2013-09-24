{_authenticator, Authenticator} = require '../../lib/client/authenticator'
{Requestor} = require '../../lib/client/requestor'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'

describe 'Authenticator', ->

    before -> 
        @config = 
            authenticator: {}

    context 'first call to authenticate()', -> 

        it 'rejects the request promise if no authentication scheme is specified', (done) -> 

            instance = Authenticator()
            instance.authenticate promised: reject: (error) -> 

                error.should.match /dinkum absence of authenticator config/

                done()


        it 'sets authenticating to the sequence number of the first request', (done) -> 

            instance = Authenticator @config
            _authenticator().authenticating.should.equal 0
            instance.authenticate sequence: 1
            _authenticator().authenticating.should.equal 1
            done()

        it 'resolves with an authentication request', (done) ->

            instance = Authenticator @config
            instance.authenticate( sequence: 1 ).then (request) -> 

                request.should.be.an.instanceof HttpRequest
                done()

        it 'suspends the queue'


    context 'subsequent calls to authenticate()', -> 

        #
        # a client that starts up with several requests in parallel
        # will receive several 401s if auth is required,
        # 
        # this authenticator directs only the first 401 through an
        # authentication sequence, subsequent requests are requeued
        # pending the authentication completion
        #




    context 'integrations', -> 

        it 'is assigned the queue via enclosed config-chain requestor..transport..', (done) -> 

            requestor = Requestor()
            should.exist _authenticator().queue
            done()

