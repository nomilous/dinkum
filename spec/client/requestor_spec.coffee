{_requestor, Requestor} = require '../../lib/client/requestor'
{_transport, Transport} = require '../../lib/client/transport'
HttpRequest = require '../../lib/client/http_request'
should = require 'should'
{defer} = require 'when'

describe 'Requestor', -> 

    context 'request', ->

        context 'enqueue', ->

            it 'creates and enqueues all new HttpRequests', (done) -> 

                instance = Requestor()
                _requestor().queue.enqueue = (httpRequest) ->
                    httpRequest.should.be.an.instanceof HttpRequest
                    done()
                    then: ->

                instance.request().then -> 


            it 'rejects when enqueue rejects', (done) -> 

                instance = Requestor()

                _requestor().queue.enqueue = -> 
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
                _requestor().queue.enqueue new HttpRequest 'PROMISED', path: '/one'
                _requestor().queue.enqueue new HttpRequest 'PROMISED', path: '/two'

                _requestor().transport.request = (request) -> return request 
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

        context 'doNext', -> 

            it 'is assigned to handle queue object::done'

            it 'calls queue.dequeue() to send the next pending requests', (done) -> 

                instance = Requestor()
                _requestor().queue.dequeue = -> done()
                _requestor().doNext()


            xit 'sends the next batch of requests that were dequeued', (done) ->

                instance = Requestor()
                _requestor().queue.dequeue = -> then: (resolve) -> resolve ['NEXT']
                

                _transport().request = -> 

                    console.log arguments
                    #
                    # wrong instance... how?
                    #

                _requestor().doNext()



