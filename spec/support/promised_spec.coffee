promised = require '../../lib/support/promised'

describe 'defers', -> 

    it 'injects a deferral at arg1 and returns the promise', -> 

        fn = promised (action) -> action.resolve 'result'
        fn().then (result) -> result.should.equal 'result'

