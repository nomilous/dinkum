{testable, create} = require '../../lib/client/queue'
should    = require 'should'

describe 'queue', -> 

    context 'enqueue', -> 

        it 'sequences an object into the queue', (done) -> 

            queue = create()
            queue.enqueue 'THING A'
            queue.enqueue 'THING B'

            testable().queued.should.eql 

                '1': object: 'THING A'
                '2': object: 'THING B'

            done()