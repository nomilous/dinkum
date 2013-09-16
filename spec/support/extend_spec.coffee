extend = require '../../lib/support/extend'
should = require 'should'

describe 'extend', -> 


    it 'appends the set of properties from a super object', (done) -> 

        SuperClass =
            authenticate: ->
            status: -> 'OK'
            
        object = extend SuperClass

        object.status().should.equal 'OK'
        done()

    it 'can have own properties', (done) ->

        SuperClass =
            authenticate: ->
            status: -> 'OK'
            
        object = extend SuperClass,
            get: -> 'GOT'
            put: ->
            post: ->
            delete: ->

        object.status().should.equal 'OK'
        object.get().should.equal 'GOT'
        done()


    it 'has own properties that override', (done) -> 

        SuperClass = 
            status: -> 'OK'

        object = extend SuperClass, 
            status: -> 'EXCELENT'

        object.status().should.equal 'EXCELENT'
        done()


    it 'can create a scoped-class factory', (done) -> 

        SuperClass = 
            authenticate: ->

        create = extend SuperClass, (superclass, tpt) -> 

            should.exist superclass.authenticate

            get: -> "got with #{tpt}" 

        instance = create 'https'
        instance.get().should.equal 'got with https'
        done()


    it 'can chain the scope into the superclass', (done) ->

        superclass = ({authtype}) -> 

            authenticate: -> "with #{authtype}"

        createClient = extend superclass, (superclass, {transport}) -> 

            #
            # internal access to scoped superclass
            #

            superclass.authenticate().should.equal "with BASIC"

            get: -> "with #{transport} that was authenticated #{superclass.authenticate()}"

        instance = createClient 

            transport: 'https'
            authtype:  'BASIC'
            
        instance.get().should.equal "with https that was authenticated with BASIC"
        done()


    it 'superclass methods default to private but can be re-exposed', (done) -> 

        superclass = ({authtype}) -> 

            authenticate: -> "with #{authtype}"

        createClient = extend superclass, (superclass) -> 

            #
            # optionally re-expose superclass method
            #
            authenticate: superclass.authenticate   
            get: -> 


        instance = createClient authtype: 'BASIC'
        instance.authenticate().should.equal 'with BASIC'
        done()
