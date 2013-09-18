should = require 'should'
{Client, Test} = require '../lib/dinkum'
{start, stop, server} = Test.HttpsServer

describe 'dinkum', -> 
    
    before (done) -> start port: 3000, done
    after (done) -> stop done


    it 'sends GET request to server', (done) -> 

        client = Client.create

            port: 3000
            allowUncertified: true


        # server.setResponse
        #     statusCode: 401
        #     headers: 'set-cookie': ['SESSION=xxxxxx;']


        client.get( path: '/login' ).then (response) ->

            server.received().method.should.equal 'GET'
            server.received().url.should.equal '/login'

            # response.headers['set-cookie'].should.eql ['SESSION=xxxxxx;']
            # response.statusCode.should.equal 401

            done()

