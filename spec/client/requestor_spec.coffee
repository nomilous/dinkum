{testable, requestor} = require '../../lib/client/requestor'
queue  = require '../../lib/client/queue'
should = require 'should'
{defer} = require 'when'

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

                A = defer()
                B = defer()
                C = defer()

                instance = requestor()
                testable().superclass.enqueue opts: { path: '/one' }, promise: A
                testable().superclass.enqueue opts: { path: '/two' }, promise: B

                testable().transport.request = (opts) -> 

                    console.log opts
                    

                instance.request( path: '/three', C ).then -> 

                    console.log 1

