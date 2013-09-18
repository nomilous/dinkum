should = require 'should'
{Client, Test} = require '../lib/dinkum'
{start,  stop} = Test.HttpsServer

describe 'dinkum', -> 
    
    before (done) -> start 3000, done
    after (done) -> stop done


    it 'requests from the server', (done) -> 

        client = Client.create

            port: 3000
            allowUncertified: true

        
        client.get( path: '/' ).then (r) -> 

            console.log r
            done()

