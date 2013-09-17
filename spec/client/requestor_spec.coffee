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
                testable().superclass.enqueue opts: { path: '/one' }, promise: 'A'
                testable().superclass.enqueue opts: { path: '/two' }, promise: 'B'

                instance.request( path: '/three', 'C' ).then -> 

                    #console.log queue.testable().active.items
                    queue.testable().pending.count.should.equal 0
                    queue.testable().active.count.should.equal 3
                    queue.testable().active.items.should.eql

                        '1': 
                            opts: path: '/one'
                            promise: 'A'

                        '2': 
                            opts: path: '/two'
                            promise: 'B'
                        '3': 
                            opts: path: '/three'
                            promise: 'C'

                    done()
