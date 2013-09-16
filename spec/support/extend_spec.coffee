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

