{testable, superclass, requestor} = require '../../lib/client/requestor'
queue  = require '../../lib/client/queue'
should = require 'should'

describe 'requestor', -> 

    context 'request', ->

        context 'enqueue', ->

            it 'enqueues all new requests', (done) -> 

                instance = requestor()
                testable().superclass.enqueue = ->
                    done()
                    then: ->

                instance.request().then ->


            it 'rejects when enqueue rejects', (done) -> 

                instance = requestor()

                testable().superclass.enqueue = -> 
                    then: (resolve, reject) -> 
                        reject new Error 'enqueue error'


                instance.request().then(
                    ->
                    (error) -> 
                        error.message.should.equal 'enqueue error'
                        done()
                )


        context 'dequeue', (done) -> 

            it 'sends already pending requests before new request', (done) ->

                instance = requestor()
                testable().superclass.enqueue opts: path: '/one'
                testable().superclass.enqueue opts: path: '/two'

                instance.request( path: '/three' ).then -> 

                    queue.testable().pending.count.should.equal 0
                    queue.testable().active.count.should.equal 3
                    queue.testable().active.items.should.eql

                        '1': opts: path: '/one'
                        '2': opts: path: '/two'
                        '3': opts: path: '/three'

                    done()
