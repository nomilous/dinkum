{_authenticator, Authenticator} = require '../../lib/client/authenticator'
{Requestor} = require '../../lib/client/requestor'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'

describe 'Authenticator', ->

    context 'first call to authenticate()', -> 

        it 'sets authenticating to true', (done) -> 

            instance = Authenticator()
            _authenticator().authenticating.should.equal false
            instance.authenticate()
            _authenticator().authenticating.should.equal true
            done()

        it 'resolves with an authentication request', (done) ->

            instance = Authenticator()
            instance.authenticate().then (request) -> 

                request.should.be.an.instanceof HttpRequest
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




    context 'integrations', -> 

        it 'is assigned the queue via enclosed config-chain requestor..transport..', (done) -> 

            requestor = Requestor()
            should.exist _authenticator().queue
            done()

