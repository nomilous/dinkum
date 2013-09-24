{_authenticator, Authenticator} = require '../../lib/client/authenticator'
{Requestor} = require '../../lib/client/requestor'
should = require 'should'

describe 'Authenticator', ->

    context 'first call to authenticate()', -> 

        it 'sets authenticating to true', (done) -> 

            instance = Authenticator()
            _authenticator().authenticating.should.equal false
            instance.authenticate()
            _authenticator().authenticating.should.equal true
            done()


    context 'integrations', -> 

        it 'is assigned the queue via enclosed config-chain requestor..transport..', (done) -> 

            requestor = Requestor()
            should.exist _authenticator().queue
            done()

