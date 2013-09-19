enclose = require '../../lib/support/enclose'
should  = require 'should'

describe 'enclose', -> 

    it 'can create a closure factory', (done) -> 

        SuperClass = 
            authenticate: ->

        create = enclose SuperClass, (superclass, tpt) -> 

            should.exist superclass.authenticate

            get: -> "got with #{tpt}" 

        instance = create 'https'
        instance.get().should.equal 'got with https'
        done()


    it 'can chain the scope into the superclass', (done) ->

        superclass = ({authtype}) -> 

            authenticate: -> "with #{authtype}"

        createClient = enclose superclass, (superclass, {transport}) -> 

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

        createClient = enclose superclass, (superclass) -> 

            #
            # optionally re-expose superclass method
            #
            authenticate: superclass.authenticate   
            get: -> 


        instance = createClient authtype: 'BASIC'
        instance.authenticate().should.equal 'with BASIC'
        done()
