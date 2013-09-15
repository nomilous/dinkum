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


            it 'rejects with Authentication Failed on second post with auth', (done) -> 

                count = 0
                https.request = (opts, callback) ->
                    if ++count == 3 then throw new Error 'should not happen'
                    callback statusCode: 401

                @session.get().then (->), (error) -> 

                    error.message.should.equal 'Authentication Failed'
                    done()


            it """does not reject with Authentication Failed on a second parallel request 
                  while the first is still waiting for an authentication reply"""


            it 'queues requests while authentication is in progress'


            it 'does not queue beyond some sensible threshold'



    context 'logging', ->

