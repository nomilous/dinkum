BasicAuth   = require '../../lib/client/basic_auth'
https       = require 'https'
should      = require 'should'

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
            @session  = BasicAuth.create
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


            it 'sends cookies if present', (done) -> 

                https.request = (opts) -> 

                    opts.headers.cookie.should.equal 'erdős-number=2; morphy-number=5;'
                    done()

                @session.cookies.setCookie [
                    'erdős-number=2;'
                    'morphy-number=5; Expires=Tue, 04-Dec-2442 19:00:00 GMT;'
                ]

                @session.get().then (response) -> 


            it 're-requests with basicauth on HTTP 401', (done) -> 

                isFirstRequest = true
                https.request = (opts, callback) ->

                    if isFirstRequest  
                        isFirstRequest = false

                        #
                        # does not send auth string on all requests
                        # -----------------------------------------
                        # 
                        # * servers may create a new session each time
                        #   it receives an auth...
                        #

                        should.not.exist opts.auth
                        callback statusCode: 401
                        return

                    #
                    # isSecondRequest
                    #

                    opts.auth.should.equal 'morning:☆'
                    done()
                    
                @session.get().then (response) -> 




