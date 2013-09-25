{RequestFilter} = require '../../lib/support'
should = require 'should'

describe 'RequestFilter', -> 

    context 'json', -> 

        it 'ammends opts (arg1) to post a json request', (done) -> 

            mockRequestor = (opts) -> 
                opts.body.should.equal '{"records":[{"a":1,"b":7}]}'
                opts.headers.should.eql 
                    'content-length': 27
                    'content-type': 'application/json'
                done()

            decoratedRequestor = RequestFilter {}, mockRequestor
            decoratedRequestor json: records: [a:1, b:7]


        it 'enables override from config', (done) -> 

            mockRequestor = (opts) -> 

                opts.body.should.equal 'JSONTEXT{"records":[{"a":1,"b":7}]}'
                done()

            config = content: json: encode: (opts) -> 

                encoded = "JSONTEXT#{JSON.stringify opts.json}"
                opts.headers ||= {}
                opts.headers['content-length'] = encoded.length
                opts.headers['content-type'] = 'application/json'
                opts.body = encoded

            decoratedRequestor = RequestFilter config, mockRequestor
            decoratedRequestor json: records: [a:1, b:7]