{functions, create} = require '../../lib/client/queue'
should    = require 'should'

describe 'queue', -> 

    it 'can be tested', (done) -> 

        functions.someFunction = done
        instance = create()
        instance.someFunction()

