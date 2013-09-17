{testable, superclass, requestor} = require '../../lib/client/requestor'
queue  = require '../../lib/client/queue'
should = require 'should'

describe 'requestor', -> 

    context 'request', ->

        it 'returns a promise', (done) -> 

            instance = requestor()
            should.exist instance.request().then
            done()

        context 'queue', ->

            it 'posts all requests onto the queue', (done) -> 

                instance = requestor()
                testable().superclass.enqueue = ->
                    done()
                    then: ->

                instance.request().then ->
