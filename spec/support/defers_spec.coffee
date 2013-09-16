defers = require '../../lib/support/defers'

describe 'defers', -> 

    it 'injects a deferral at arg1 and returns the promise', -> 

        fn = defers (promised) -> promised.resolve 'result'
        fn().then (result) -> result.should.equal 'result'
