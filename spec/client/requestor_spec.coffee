{testable, superclass, requestor} = require '../../lib/client/requestor'
should = require 'should'

describe 'requestor', -> 

    context 'request', ->

        it 'posts all requests onto the queue', (done) -> 

            instance = requestor()
            testable().superclass.enqueue = done
            instance.request()
