{_queue, Queue} = require '../../lib/client/queue'
should = require 'should'

describe 'Queue', -> 

    context 'enqueue', -> 

        it 'sequences objects onto the pending queue', (done) -> 

            instance = Queue()
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'

            _queue().pending.should.eql 

                count: 2
                items: 
                    '1': thing: 'A', sequence: 1
                    '2': thing: 'B', sequence: 2

            done()

        it 'allows for future persistable queue', (done) -> 

            instance = Queue()
            instance.enqueue('THING A').then -> done() # saving to queue

        it 'rejects on queueLimit overflow', (done) -> 

            instance = Queue 

                queueLimit: 1

            instance.enqueue thing: 'A'
            instance.enqueue( thing: 'B' ).then (->), (error) -> 

                error.message.should.equal 'dinkum queue overflow'
                done()
        

    context 'dequeue', ->

        it 'transfers items onto the active queue', (done) -> 

            instance = Queue()
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'
            instance.dequeue()

            process.nextTick ->

                _queue().pending.should.eql 
                    count: 0
                    items: {}
                _queue().active.should.eql
                    count: 2
                    items: 
                        '1': thing: 'A', sequence: 1
                        '2': thing: 'B', sequence: 2

                done()


        it 'resolves with the array of dequeued objects', (done) -> 

            instance = Queue()

            instance.enqueue 'THING A'

            instance.dequeue().then (objects) -> 

                objects.should.eql [ 'THING A' ]
                done()

        it 'resolves with empty array when the queue is empty', (done) ->

            instance = Queue()
            instance.dequeue().then (objects) -> 

                objects.length.should.equal 0
                done()


        it 'requestLimit dequeue according to the number of objects on the active queue', (done) -> 

            instance = Queue requestLimit: 4
                
            instance.enqueue thing: 'A'
            instance.enqueue thing: 'B'
            instance.enqueue thing: 'C'
            instance.enqueue thing: 'D'
            instance.enqueue thing: 'E'

            instance.dequeue().then (objects) -> 

                #console.log objects

                objects.length.should.equal 4
                _queue().pending.should.eql 
                    count: 1
                    items: 
                        '5': thing: 'E', sequence: 5
                done()


    context 'queue.update', ->

        it 'can advance object state to done', (done) ->

            instance = Queue()
            instance.enqueue( object: 'A' ).then ->
                instance.dequeue().then (objects) ->

                    instance.update( 'done', objects[0] ).then ->

                        instance.stats().then (stats) ->
                            _queue().active.items.should.eql {}
                            stats.active.count.should.equal 0
                            stats.done.count.should.equal 1
                            done()




    context 'queue.redo', -> 

        it 'requeues objects back onto the front of the queue', (done) -> 

            sequence = require 'when/sequence'
            instance = Queue requestLimit: 3
            sequence([
                -> instance.enqueue object: 'A'
                -> instance.enqueue object: 'B'
                -> instance.enqueue object: 'C'
                -> instance.enqueue object: 'D'
            ]).then -> instance.dequeue().then (objects) -> 

                sequence([
                    -> instance.update 'done', objects[1]
                    -> instance.update 'done', objects[2]
                    -> instance.requeue objects[0]
                    -> instance.dequeue()
                ]).then ([done1, done2, requeued, dequeued]) -> 

                    dequeued.should.eql [
                        { object: 'A', sequence: 1 }
                        { object: 'D', sequence: 4 }
                    ]

                    done()


        it 'removes requeued ojects from the active list', (done) -> 

            instance = Queue()
            instance.enqueue( object: 'A' ).then ->
                instance.dequeue().then (objects) -> 
                    instance.requeue( objects[0] ).then -> 

                        should.not.exist _queue().active.items['1']
                        done()


    context 'queue.suspend', ->

        it 'causes dequeue to resolve with an empty array', (done) ->

            instance = Queue()
            instance.enqueue( object: 'A' ).then -> 
                instance.suspend
                instance.dequeue().then (objects) ->
                    objects.should.eql []
                    done()


    context 'queue.resume', ->

        it 'causes dequeue to resolve with an empty array', (done) ->

            instance = Queue()
            instance.enqueue( object: 'A' ).then ->
                instance.suspend
                instance.dequeue().then (objects) ->
                    objects.should.eql []
                    instance.resume
                    instance.dequeue().then (objects) ->
                        objects.should.eql [ { object: 'A', sequence: 1 } ]
                        done()
                    

    context 'queue.stats', -> 

        it 'provides report on status', (done) -> 

            instance = Queue

                queueLimit: 1000
                requestLimit:  100

            instance.enqueue {thing: i} for i in [0..9999]
            instance.dequeue()

            process.nextTick -> 
                instance.stats().then (stats) -> 
                    stats.should.eql

                        pending: count: 900
                        active:  count: 100
                        done:    count: 0

                    done()




