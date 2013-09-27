{ResponseFilter} = require '../../lib/support'
should = require 'should'

describe 'ResponseFilter', -> 

    context 'application/json', -> 

        it 'decodes message body as json per that content-type', (done) -> 

            httpResult = 
                headers: 'content-type': 'application/json'
                body: '{"test":1}'

            filter = ResponseFilter {}
            filter httpResult
            httpResult.body.should.eql test: 1
            done()

        it 'uses the first field from the content type header', (done) ->

            httpResult = 
                headers: 'content-type': 'application/json; charset=utf-8;'
                body: '{"test":1}'

            filter = ResponseFilter {}
            filter httpResult
            httpResult.body.should.eql test: 1
            done()


        it 'enables override from config', (done) -> 

            httpResult = 
                headers: 'content-type': 'application/json'
                body: 'JSONDATA{"test":1}'

            filter = ResponseFilter 
                content:
                    'application/json':
                        decode: (httpResult) -> 
                            httpResult.body = JSON.parse httpResult.body.match(/JSONDATA(.*)/)[1]

            filter httpResult
            httpResult.body.should.eql test: 1
            done()
