{testable, Requestor} = require '../../lib/client/requestor'
Queue  = require '../../lib/client/queue'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'
{defer} = require 'when'

describe 'Requestor', -> 

    context 'request', ->

        context 'enqueue', ->

            it 'creates and enqueues all new HttpRequests', (done) -> 

                instance = Requestor()
                testable().queue.enqueue = (httpRequest) ->
                    httpRequest.should.be.an.instanceof HttpRequest
                    done()
                    then: ->

                instance.request().then -> 


            it 'rejects when enqueue rejects', (done) -> 

                instance = Requestor()

                testable().queue.enqueue = -> 
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

                instance = Requestor()
                testable().queue.enqueue new HttpRequest 'PROMISED', path: '/one'
                testable().queue.enqueue new HttpRequest 'PROMISED', path: '/two'

                testable().transport.request = (request) -> return request 
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

        context 'done', -> 

            it 'is assigned to handle HttpRequest.onDone()', (done) ->

                instance = Requestor()
                testable().queue.enqueue = (httpRequest) ->

                    #
                    # set the new request to done immediately
                    #

                    httpRequest.state = 'done'
                    

                testable().done = (error, httpRequest) ->

                    #
                    # this should be been called with the done request
                    #

                    httpRequest.state.should.equal 'done'
                    httpRequest.opts.path.should.equal '/path/1'
                    done()

                instance.request path: '/path/1'


            it 'calls queue.done() with the httpRequest just completed', (done) -> 

                instance = Requestor()
                testable().queue.done = (error, object) -> done()
                testable().done 'ERROR', 'REQUEST'


            xit 'calls queue.dequeue() to send the next pending requests', (done) -> 

                instance = Requestor()
                testable().queue.dequeue = -> done()
                testable().done 'ERROR', 'REQUEST'


            it 'sends the next batch of requests that were dequeued'


