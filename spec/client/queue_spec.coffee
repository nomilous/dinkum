{testable, queue} = require '../../lib/client/queue'
should = require 'should'

describe 'queue', -> 

    context 'enqueue', -> 

        it 'sequences objects onto the queue', (done) -> 

            instance = queue()
            instance.enqueue 'THING A'
            instance.enqueue 'THING B'

            testable().queued.should.eql 

                count: 2
                items: 
                    '1': object: 'THING A'
                    '2': object: 'THING B'

            done()
