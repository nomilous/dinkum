BasicAuth   = require '../../lib/client/basic_auth'
https       = require 'https'
should      = require 'should'

describe 'BasicAuth', -> 

    beforeEach -> 
        @request = https.request
        @now = Date.now

    afterEach -> 
        https.request = @request
        Date.now = @now

    it 'pays no attention to realm at this time' 

    it 'requires hostname username password', (done) -> 

        try BasicAuth.create 

            username: 'evening'
            password: '☆'
            hostname: undefined

        catch error

            error.should.match /requires config.username, config.password, config.hostname/
            done()

    context 'status', -> 

        it 'reports on requests pending and requests in progress', (done) -> 

            Date.now = -> 1 
            first = true
            https.request = (opts, callback) -> 
                if first
                    first = false
                    callback 
                        statusCode: 401
                        on: ->

            session = BasicAuth.create

                hostname: 'www.www.www'
                username: 'www'
                password: 'y'


            session.get(path: '/path/one').then   (response) -> responses.first  = response
            session.get(path: '/path/two').then   (response) -> responses.second = response
            session.get(path: '/path/three').then (response) -> responses.third  = response

            process.nextTick ->
                
                #console.log JSON.stringify @session.status(),null, 2
                session.queued.should.equal 2
                session.active.should.equal 1
                session.status().should.eql 
                    queued: 
                        count: 2
                        requests: 
                            '3': 
                                status:    'pending auth'
                                statusAge: 0
                                path:      '/path/two'
                            '4':
                                status:    'pending auth'
                                statusAge: 0
                                path:      '/path/three'
                    active: 
                        count: 1
                        requests: 
                            '2':
                                status:   'sent'
                                statusAge: 0
                                path:     '/path/one'

                    done: 
                        total: 0
                done()


    context 'methods', -> 

        context 'get', -> 

            it 'returns a promise', (done) -> 

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'

                https.request = -> 
                should.exist session.get().then
                done()


            it 'defaults opts if unspecified', (done) -> 

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'

                https.request = (opts) -> 
                    opts.port.should.equal 443
                    opts.path.should.equal '/'
                    done()

                session.get().then (response) -> 


            it 'sends cookies if present', (done) -> 

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'

                https.request = (opts) -> 

                    opts.headers.cookie.should.equal 'erdős-number=2; morphy-number=5;'
                    done()

                session.cookies.setCookie [
                    'erdős-number=2;'
                    'morphy-number=5; Expires=Tue, 04-Dec-2442 19:00:00 GMT;'
                ]

                session.get().then (response) -> 


        context 'auth', ->

            it 'rejects with Authentication Failed 401 as response to authentication attempt', (done) -> 

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'

                count = 0
                https.request = (opts, callback) ->
                    if count++ == 2 then throw new Error 'should not happen'
                    process.nextTick -> callback 
                        statusCode: 401
                        on: ->

                session.get().then (->), (error) -> 

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

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'

                https.request = (opts, callback) ->
                    
                errors = {}
                session.get().then (->), (error) -> errors.request1 = error 
                session.get().then (->), (error) -> errors.request2 = error 

                setTimeout (->

                    should.not.exist errors.request1
                    should.not.exist errors.request2
                    done()


                ), 100


        context 'auth queue', ->

            



            xit 'queues on 401s that follow the first unauthorized response', (done) ->

                throw new Error 'this test needs attention'

                session  = BasicAuth.create

                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'
                    rateLimit: 3

                #
                # client could start more than one activity in parallel
                # leading to multiple 401s
                #
                firsts = 
                    '/1': true
                    '/2': true
                    '/3': true

                results = 
                    '401': count: 0
                    authrequests: count: 0

                https.request = (opts, callback) -> 

                    if firsts[opts.path]
                        #
                        # multiple first requests in parallel, 
                        # each receives 401
                        #
                        firsts[opts.path] = false
                        return process.nextTick -> 
                            results['401'].count++
                            callback 
                                statusCode: 401
                                on: (event, listener) -> if event == 'end' then listener()

                    if opts.auth? then results.authrequests.count++

                    setTimeout (->
                        callback 
                            statusCode: 200
                            on: (event, listener) -> 
                                #
                                # second attempt for each resolves
                                #
                                if event == 'end' then listener()

                    ), 100

                responses = {}
                session.get(path: '/1').then  (response) -> responses.first  = response
                session.get(path: '/2').then  (response) -> responses.second = response
                session.get(path: '/3').then  (response) -> responses.third  = response

                setTimeout (->

                    #
                    # 3 requests were 401nd
                    # only 1 auth has been sent
                    #

                    results.should.eql 
                        '401': count: 3
                        authrequests: count: 1

                    #
                    # no result yet
                    #

                    responses.should.eql first:  {}
                ), 50

                setTimeout (->

                    #
                    # only 1 auth was ever sent
                    #

                    results.should.eql 
                        '401': count: 3
                        authrequests: count: 1

                    #
                    # all three have result
                    #

                    console.log '???': responses
                    done()
                    

                    responses.should.eql  
                        first:  {}
                        second: {}
                        third:  {}
                    
                ), 300


            it 'can control concurrency limit', (done) -> 

                session  = BasicAuth.create
                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'
                    rateLimit: 2

                https.request = (opts, callback) -> 

                session.get()
                session.get()
                session.get()
                session.get()
                session.get()

                session.queued.should.equal 3
                session.active.should.equal 2


                done()

            it 'sends queued requests before new requests', (done) -> 

                seq = 0
                https.request = (opts, callback) -> 
                    do (seq = ++seq) -> 
                        process.nextTick -> 
                            callback 
                                statusCode: 200
                                headers: []
                                on: (event, listener) -> 
                                    if event == 'data' then listener seq + ' ' + opts.path
                                    if event == 'end' then listener()

                session = BasicAuth.create

                    hostname: 'localhost'
                    username: 'morning'
                    password: '☆'
                    rateLimit: 1

                responses = []
                session.get(path: '/one').then   (r) -> 

                    responses.push r
                    session.get(path: '/six').then (r) -> 

                        responses.push r
                        session.get(path: '/9ine').then (r) -> responses.push r
                        session.get(path: '/ten').then (r) -> responses.push r

                    session.get(path: '/seven').then (r) -> responses.push r
                    session.get(path: '/eight').then (r) -> responses.push r

                session.get(path: '/two').then   (r) -> responses.push r
                session.get(path: '/three').then (r) -> responses.push r
                session.get(path: '/four').then  (r) -> responses.push r
                session.get(path: '/five').then  (r) -> responses.push r


                # console.log JSON.stringify session.status(), null, 2


                setTimeout (-> 

                    #console.log responses.map (r) -> r.body
                    responses.map( (r) -> r.body ).should.eql [

                        '1 /one'
                        '2 /two'
                        '3 /three'
                        '4 /four'
                        '5 /five'
                        '6 /six'
                        '7 /seven'
                        '8 /eight'
                        '9 /9ine'
                        '10 /ten'

                    ]
                    done()

                ), 2  # <----------- first stop (for if this tests starts failing)


            it 'dequeues at new request'
            it 'dequeues at response end'
            it 'pends requests while authentication is in progress'
            it 'starts an authentication on 401'
            it 'cannot queue an authentication attempt'
            it 'rejects all queued requests on authentication failure'
            it 'rejects if queue size reaches queueLimit'



    context 'logging', ->

