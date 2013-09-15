BasicAuth = require '../../lib/client/basic_auth'
https     = require 'https'
should    = require 'should'

describe 'BasicAuth', -> 

    it 'pays no attention to realm at this time' 

    it 'requires hostname username password', (done) -> 

        try BasicAuth.create 

            username: 'evening'
            password: '☆'
            hostname: undefined

        catch error

            error.should.match /requires config.username, config.password, config.hostname/
            done()

    context 'methods', -> 

        before -> 

            @session = BasicAuth.create

                hostname: 'localhost'
                username: 'morning'
                password: '☆'

        beforeEach -> 

            @request = https.request

        afterEach -> 

            https.request = @request

        context 'get', -> 

            it 'returns a promise', (done) -> 

                https.request = -> 
                should.exist @session.get().then
                done()

            it 'defaults opts if unspecified', (done) -> 

                https.request = (opts) -> 

                    opts.port.should.equal 443
                    opts.path.should.equal '/'
                    done()

                @session.get().then (response) -> 


