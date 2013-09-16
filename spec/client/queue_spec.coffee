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
                count: 0
                items: {}
            testable().active.should.eql
                count: 2
                items: 
                    '1': object: 'THING A'
                    '2': object: 'THING B'

            done()


        it 'resolves with the array of dequeued objects', (done) -> 

            instance = queue()

            instance.enqueue 'THING A'

            instance.dequeue().then (objects) -> 

                objects.should.eql [ { object: 'THING A' } ]
                done()

        it 'resolves with empty array when the queue is empty', (done) ->

            instance = queue()
            instance.dequeue().then (objects) -> 

                objects.length.should.equal 0
                done()


        it 'rateLimits dequeue according to the number of objects on the active queue', (done) -> 

            instance = queue rateLimit: 4
                
            instance.enqueue 'THING A'
            instance.enqueue 'THING B'
            instance.enqueue 'THING C'
            instance.enqueue 'THING D'
            instance.enqueue 'THING E'

            instance.dequeue().then (objects) -> 

                #console.log objects

                objects.length.should.equal 4
                testable().pending.should.eql 
                    count: 1
                    items: 
                        '5': object: 'THING E'
                done()


    context 'queue.status', -> 

        it 'provides report on status', (done) -> 

            instance = queue

                queueLimit: 1000
                rateLimit:  100

            instance.enqueue 'THING' for i in [0..9999]
            instance.dequeue()
            instance.queue.stats().then (stats) -> 

                stats.should.eql

                    pending: count: 900
                    active:  count: 100

                done()




