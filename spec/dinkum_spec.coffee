should = require 'should'
{Client, Test} = require '../lib/dinkum'
{start, stop, server} = Test.HttpsServer

describe 'dinkum', -> 
    
    before (done) -> start port: 3001, done
    after (done) -> stop done


    it 'sends GET request to server', (done) -> 

        server.log.off
        client = Client.create

            port: 3001
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


    it 'sends multiple requests in parallel', (done) -> 

        server.log.on
        parallel = require 'when/parallel'

        client = Client.create

            requestLimit: 2  # limit to 2 at a time
            port: 3001
            allowUncertified: true
            


        parallel( for i in [0..9]

            do (i) -> -> client.get path: '/test/' + i

        ).then( 

            (results) -> 

                console.log RESULTS: results
                done()

            (error) -> 

                console.log ERROR: error
                done()

        )

