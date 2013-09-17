{testable, client} = require '../../lib/client/client'
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

                instance = client()
                testable().superclass.request = -> done()

                instance.get path: '/'


            it 'sets method GET', (done) -> 

                instance = client()
                testable().superclass.request = (opts) ->
                    opts.method.should.equal 'GET'
                    done()

                instance.get path: '/'


            # it 'returns the promise that the request will be sent', (done) -> 
            #     instance = client()
            #     testable().superclass.request = -> return 'the promise to send request'
            #     instance.get( path: '/' ).should.equal 'the promise to send request'
            #     done()


            it 'passes the result promise to the requestor', (done) -> 

                instance = client()
                testable().superclass.request = (opts, result) -> 
                    result.should.equal 'the promise to return a result'
                    done()

                instance.get path: '/', 'the promise to return a result'


            it 'will generate a new result promise if not provided', (done) -> 

                instance = client()
                testable().superclass.request = (opts, result) -> 

                    should.exist result.resolver
                    done()

                instance.get path: '/'


        context 'HEAD', -> 
        context 'POST', -> 
        context 'PUT', ->
        context 'DELETE', ->

    context 'extended methods', ->

        context 'TRACE', ->
        context 'OPTIONS', ->
        context 'CONNECT', ->
        context 'PATCH', -> 

