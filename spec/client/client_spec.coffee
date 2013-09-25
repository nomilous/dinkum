{_client, Client} = require '../../lib/client/client'
{RequestFilter} = require '../../lib/support' 
should = require 'should'

describe 'Client', ->

    context 'session', -> 

        context 'authentication', ->
        context 'cookies', -> 

    context 'status', -> 

        context 'active', -> 
        context 'pending', -> 

    context 'core methods', -> 

        context 'GET', -> 


            it 'calls requestor.request', (done) -> 

                instance = Client()
                _client().requestor.request = -> 
                    done()
                    then: ->

                instance.get path: '/'


            it 'sets method GET', (done) -> 

                instance = Client()
                _client().requestor.request = (opts) ->
                    opts.method.should.equal 'GET'
                    done()
                    then: ->

                instance.get path: '/'


            it 'accepts an existing promise of a result and passes it to the requestor', (done) -> 

                instance = Client()
                _client().requestor.request = (opts, result) -> 
                    result.should.equal 'the deferral of a promise to return a result'
                    done()
                    then: ->

                instance.get path: '/', 'the deferral of a promise to return a result'


            it 'will generate a new result promise if not provided', (done) -> 

                instance = Client()
                _client().requestor.request = (opts, result) -> 

                    should.exist result.resolver
                    done()
                    then: ->

                instance.get path: '/'


            it 'returns the result promise', (done) -> 

                instance = Client()
                _client().requestor.request = (opts, result) -> then: ->
                    
                instance.get( path: '/', { promise: 'THE RESULT' } ).should.equal 'THE RESULT'
                done()


            #
            # possibly useful
            #
            # it 'returns the promise that the request will be sent', (done) -> 
            #     instance = Client()
            #     _client().requestor.request = -> return 'the promise to send request'
            #     instance.get( path: '/' ).should.equal 'the promise to send request'
            #     done()
            # 


        context 'HEAD', -> 
        context 'POST', -> 

            it 'calls requestor.request', (done) ->

                instance = Client()
                _client().requestor.request = -> 
                    done()
                    then: ->

                instance.post path: '/'


            it 'sets method POST', (done) -> 

                instance = Client()
                _client().requestor.request = (opts) ->
                    opts.method.should.equal 'POST'
                    done()
                    then: ->

                instance.post path: '/'


            it 'processes opts through the json request filter if opts.json was passed to post', (done) -> 

                instance = Client()
                RequestFilter.filters.json = (opts) -> 
                    opts.json.should.eql records: {}
                    done()

                instance.post path: '/', json: records: {}


            it.only 'can override the default request filter', (done) -> 

                instance = Client
                    content: json: (opts) -> 
                        opts.json.should.eql records: {}
                        done()

                instance.post path: '/', json: records: {}



        context 'PUT', ->
        context 'DELETE', ->

    context 'extended methods', ->

        context 'TRACE', ->
        context 'OPTIONS', ->
        context 'CONNECT', ->
        context 'PATCH', -> 

