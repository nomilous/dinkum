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
                testable().superclass.enqueue = (httpRequest) ->
                    httpRequest.should.be.an.instanceof HttpRequest
                    done()
                    then: ->

                instance.request().then -> 


            it 'assigns requestor.done() to handle HttpRequest.onDone()', (done) ->

                instance = requestor()
                testable().superclass.enqueue = (httpRequest) ->

                    #
                    # set the new request to done immediately
                    #

                    httpRequest.state = 'done'
                    

                console.log testable().done = (error, httpRequest) ->

                    #
                    # this should be been called with the done request
                    #

                    httpRequest.state.should.equal 'done'
                    httpRequest.opts.path.should.equal '/path/1'
                    done()

                instance.request path: '/path/1'



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

                instance = requestor()
                testable().superclass.enqueue new HttpRequest 'PROMISED', path: '/one'
                testable().superclass.enqueue new HttpRequest 'PROMISED', path: '/two'

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

