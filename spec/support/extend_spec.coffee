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
            status: -> 'OK'


        create = extend SuperClass, (tpt) -> 
            get: -> "got with #{tpt}"
                

        instance = create 'https'

        instance.get().should.equal 'got with https'
        instance.status().should.equal 'OK'
        done()


    it 'can chain the scope into the superclass', (done) ->

        superclass = ({authtype}) -> 

            authenticate: -> "with #{authtype}"

        createClient = extend superclass, ({transport}) -> 

            get: -> "with #{transport}"

        instance = createClient 

            transport: 'https'
            authtype:  'basic'
            
        instance.get().should.equal "with https"
        instance.authenticate().should.equal "with basic"
        done()


    it 'defaults if the factory returns null', (done) -> 

        superclass = -> function: -> 
        create     = extend superclass, -> return null
        instance   = create()
        should.exist instance.function
        done()


    is: it 'a', (bird) -> 

        hyperclass = -> x: -> 1
        ultraclass = extend hyperclass, -> y: -> 0
        superclass = extend ultraclass, -> z: -> 0
        Class      = extend superclass, -> w: -> 0
        instance   = Class()
        instance.x().should.equal 1
        bird()

