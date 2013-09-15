BasicAuth = require '../../lib/client/basic_auth'
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

        context 'get', -> 

            it 'returns a promise', (done) -> 

                should.exist @session.get().then
                done()

