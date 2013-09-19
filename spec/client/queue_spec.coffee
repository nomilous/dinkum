{testable, queue} = require '../../lib/client/queue'
should = require 'should'

describe 'queue', -> 

    xcontext 'enqueue', -> 

        it 'sequences objects onto the pending queue', (done) -> 

            instance = queue()
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'

            testable().pending.should.eql 

                count: 2
                items: 
                    '1': thing: 'A', sequence: 1
                    '2': thing: 'B', sequence: 2

            done()

        it 'allows for future persistable queue', (done) -> 

            instance = queue()
            instance.enqueue('THING A').then -> done() # saving to queue

        it 'rejects on queueLimit overflow', (done) -> 

            instance = queue 

                queueLimit: 1

            instance.enqueue thing: 'A'
            instance.enqueue( thing: 'B' ).then (->), (error) -> 

                error.message.should.equal 'dinkum queue overflow'
                done()
        

    context 'dequeue', ->

        it 'transfers items onto the active queue', (done) -> 

            instance = queue()
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'
            instance.dequeue()

            process.nextTick ->

                testable().pending.should.eql 
                    count: 0
                    items: {}
                testable().active.should.eql
                    count: 2
                    items: 
                        '1': thing: 'A', sequence: 1
                        '2': thing: 'B', sequence: 2

                done()


        it 'resolves with the array of dequeued objects', (done) -> 

            instance = queue()

            instance.enqueue 'THING A'

            instance.dequeue().then (objects) -> 

                objects.should.eql [ 'THING A' ]
                done()

        it 'resolves with empty array when the queue is empty', (done) ->

            instance = queue()
            instance.dequeue().then (objects) -> 

                objects.length.should.equal 0
                done()


        it 'requestLimit dequeue according to the number of objects on the active queue', (done) -> 

            instance = queue requestLimit: 4
                
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'
            instance.enqueue thing: 'C'
            instance.enqueue thing: 'D'
            instance.enqueue thing: 'E'

            instance.dequeue().then (objects) -> 

                #console.log objects

                objects.length.should.equal 4
                testable().pending.should.eql 
                    count: 1
                    items: 
                        '5': thing: 'E', sequence: 5
                done()


    context 'queue.status', -> 

        it 'provides report on status', (done) -> 

            instance = queue

                queueLimit: 1000
                requestLimit:  100

            instance.enqueue {thing: i} for i in [0..9999]
            instance.dequeue()

            process.nextTick -> 
                instance.queue.stats().then (stats) -> 
                    stats.should.eql

                        pending: count: 900
                        active:  count: 100

                    done()




