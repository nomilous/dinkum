deferred = require '../../lib/support/deferred'

describe 'defers', -> 

    it 'injects a deferral at arg1 and returns the promise', -> 

        fn = deferred (action) -> action.resolve 'result'
        fn().then (result) -> result.should.equal 'result'

