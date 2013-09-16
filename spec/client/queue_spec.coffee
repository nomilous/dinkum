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

        it 'rejects on queueLimit overflow', (done) -> 

            instance = queue 

                queueLimit: 1

            instance.enqueue 'THING A'
            instance.enqueue('THING B').then (->), (error) -> 

                error.message.should.equal 'dinkum queue overflow'
                done()
        

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


        it 'resolves with the array of dequeued objects', (done) -> 

            instance = queue()
            instance.enqueue 'THING A'
            instance.enqueue 'THING B'

            instance.dequeue().then (objects) -> 

                objects.should.eql [ { object: 'THING A' } ]
                done()

