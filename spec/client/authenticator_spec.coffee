{_authenticator, Authenticator} = require '../../lib/client/authenticator'
{Requestor} = require '../../lib/client/requestor'
should = require 'should'

describe 'Authenticator', ->

    context 'authenticate', -> 

    context 'integrations', -> 

        it 'is assigned the queue via enclosed config-chain requestor..trnasport..', (done) -> 

            requestor = Requestor()
            should.exist _authenticator().queue
            done()