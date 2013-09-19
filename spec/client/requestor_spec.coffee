{testable, requestor} = require '../../lib/client/requestor'
queue  = require '../../lib/client/queue'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'
{defer} = require 'when'

describe 'requestor', -> 

    context 'request', ->

        context 'enqueue', ->

            it 'creates and enqueues all new HttpRequests', (done) -> 

                instance = requestor()
                testable().superclass.enqueue = (object) ->
                    object.should.be.an.instanceof HttpRequest
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

            it 'dequeues already pending requests before new ones', (done) ->

                # A = defer()
                # B = defer()
                # C = defer()

                instance = requestor()
                testable().superclass.enqueue new HttpRequest 'PROMISED', path: '/one'
                testable().superclass.enqueue new HttpRequest 'PROMISED', path: '/two'

                testable().transport.request = (request) -> request 
                            #
                            # 
                            # stub transport to respond with the unsent HttpRequest
                            # so that the next request's dequeue resolves with the
                            # the 3 dequeued HttpRequests
                            #   
                            # 
                instance.request( path: '/three', 'PROMISED' ).then (transportResults) -> 

                    transportResults.map( 

                        (r) -> 

                            seq: r.sequence
                            path: r.opts.path

                    ).should.eql [ 
                        { seq: 1, path: '/one'   }
                        { seq: 2, path: '/two'   }
                        { seq: 3, path: '/three' } 
                    ]

                    done()

