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


        xcontext 'get', -> 


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


        xcontext 'auth', ->

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
                        process.nextTick -> callback 
                            statusCode: 401
                            on: ->
                        return

                    #
                    # isSecondRequest
                    #
                    opts.auth.should.equal 'morning:☆'
                    process.nextTick -> callback 
                        on: (event, listener) -> 
                            if event == 'end' then listener()
                    

                @session.get().then (response) -> done()


            it 'rejects with Authentication Failed 401 as response to authentication attempt', (done) -> 

                count = 0
                https.request = (opts, callback) ->
                    if count++ == 2 then throw new Error 'should not happen'
                    process.nextTick -> callback 
                        statusCode: 401
                        on: ->

                @session.get().then (->), (error) -> 

                    error.message.should.equal 'Authentication Failed'
                    done()

            it 'can specify config.strictAuth and on when header www-authenticate = BASIC is also set' 
            it 'pays attention to realm' 
                # 
                # header: 'www-authenticate': 'BASIC realm="Realm-Name"'
                # 
                # and, What does that """actualy""" mean?
                # 



            it """does not reject with Authentication Failed on a second parallel request 
                  while the first is still waiting for an authentication reply""", (done) -> 


                https.request = (opts, callback) ->
                    
                errors = {}
                @session.get().then (->), (error) -> errors.request1 = error 
                @session.get().then (->), (error) -> errors.request2 = error 

                setTimeout (->

                    should.not.exist errors.request1
                    should.not.exist errors.request2
                    done()


                ), 100


        context 'auth queue', ->

            it 'pends requests while authentication is in progress', (BigBeltBuckle) -> 

                flyWeight      = 100
                welterWeight   = 150
                heavyWeight    = 200

                firstRequest   = true
                authInProgress = false
                https.request = (opts, callback) -> 

                    if firstRequest then return process.nextTick -> 
                        firstRequest = false
                        authInProgress = true
                        callback 
                            statusCode: 401
                            on: ->

                    setTimeout (-> 

                        callback
                            #
                            # mock response object that fakes 200 and emits the
                            # inbound data stream completed event, to cause the
                            # promises to resolve
                            #
                            statusCode: 200
                            on: (event, listener) -> 

                                if event == 'end'

                                    listener()

                    ), welterWeight


                responses = {}
                @session.get().then  (response) -> responses.first  = response
                @session.get().then  (response) -> responses.second = response
                @session.get().then  (response) -> responses.third  = response


                setTimeout (->

                    authInProgress.should.equal true
                    should.not.exist responses.first
                    should.not.exist responses.second
                    should.not.exist responses.third

                ), flyWeight

                setTimeout (->

                    console.log responses
                    should.exist responses.first
                    # should.exist responses.second
                    # should.exist responses.third
                    BigBeltBuckle()

                ), heavyWeight


            it 'does not queue beyond some sensible threshold'



    context 'logging', ->

