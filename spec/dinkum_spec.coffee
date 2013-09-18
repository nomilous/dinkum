should = require 'should'
{Client, Test} = require '../lib/dinkum'
{start, stop, server} = Test.HttpsServer

describe 'dinkum', -> 
    
    before (done) -> start port: 3000, keep: 1, done
    after (done) -> stop done


    it 'sends GET request to server', (done) -> 

        client = Client.create

            port: 3000
            allowUncertified: true

        
        client.get( path: '/get/this/thing' ).then -> 

            server.latest().method.should.equal 'GET'
            server.latest().url.should.equal '/get/this/thing'
            done()

