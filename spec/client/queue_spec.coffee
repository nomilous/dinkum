{testable, queue} = require '../../lib/client/queue'
should = require 'should'

describe 'queue', -> 

    context 'enqueue', -> 

        it 'sequences objects onto the pending queue', (done) -> 

            instance = queue()
            instance.enqueue 'THING A'
            instance.enqueue 'THING B'

            testable().pending.should.eql 

                count: 2
                items: 
                    '1': object: 'THING A'
                    '2': object: 'THING B'

            done()

        it 'allows for future persistable queue', (done) -> 

            instance = queue()
            instance.enqueue('THING A').then -> done() # saving to queue
        

    context 'dequeue', ->

        it 'transfers items onto the active queue', (done) -> 

            instance = queue()
            instance.enqueue 'THING A'
            instance.enqueue 'THING B'
            instance.dequeue() 

            testable().pending.should.eql 
                count: 1
                items: 
                    '2': object: 'THING B'

            testable().active.should.eql
                count: 1
                items: 
                    '1': object: 'THING A'

            done()

