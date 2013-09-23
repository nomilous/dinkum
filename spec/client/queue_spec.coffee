{testable, queue} = require '../../lib/client/queue'
should = require 'should'

describe 'queue', -> 

    context 'enqueue', -> 

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


    context 'queue.redo', -> 

        it 'requeues objects back onto the front of the queue', (done) -> 

            sequence = require 'when/sequence'
            instance = queue requestLimit: 3
            sequence([
                -> instance.enqueue object: 'A'
                -> instance.enqueue object: 'B'
                -> instance.enqueue object: 'C'
                -> instance.enqueue object: 'D'
            ]).then -> instance.dequeue().then (objects) -> 
                sequence([
                    -> instance.done null, objects[1]
                    -> instance.done null, objects[2]
                    -> instance.requeue objects[0]
                    -> instance.dequeue()
                ]).then ([done1, done2, requeued, dequeued]) -> 

                    dequeued.should.eql [
                        { object: 'A', sequence: 1 }
                        { object: 'D', sequence: 4 }
                    ]

                    done()


        it 'removes requeued ojects from the active list', (done) -> 

            instance = queue()
            instance.enqueue( object: 'A' ).then ->
                instance.dequeue().then (objects) -> 
                    instance.requeue( objects[0] ).then -> 

                        should.not.exist testable().active.items['1']
                        done()


    context 'queue.suspend', ->

        it 'causes dequeue to resolve with an empty array', (done) ->

            instance = queue()
            instance.enqueue( object: 'A' ).then -> 
                instance.suspend
                instance.dequeue().then (objects) ->
                    objects.should.eql []
                    done()


    context 'queue.resume', ->

        it 'causes dequeue to resolve with an empty array', (done) ->

            instance = queue()
            instance.enqueue( object: 'A' ).then ->
                instance.suspend
                instance.dequeue().then (objects) ->
                    objects.should.eql []
                    instance.resume
                    instance.dequeue().then (objects) ->
                        objects.should.eql [ { object: 'A', sequence: 1 } ]
                        done()
                    

    context 'queue.done', ->

        it 'removes done object from the active list', (done) ->

            instance = queue()
            instance.enqueue( object: 'A' ).then ->
                instance.dequeue().then (objects) ->
                    error = null
                    instance.done( error, objects[0] ).then ->
                        instance.queue.stats().then (stats) ->

                            testable().active.items.should.eql {}
                            stats.active.count.should.equal 0
                            stats.done.count.should.equal 1
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
                        done:    count: 0

                    done()




