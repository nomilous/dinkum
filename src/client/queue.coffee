{deferred} = require '../support'
{EventEmitter} = require 'events'

testable = undefined
exports._queue = -> testable

exports.Queue = (config = {}) -> 

    queue = 

        sequence: 0
        suspended: false
        emitter: new EventEmitter
        pending: 
            count: 0
            items: {}
        active:
            count: 0
            items: {}
        redo: 
            count: 0
            items: {}
        finished: 
            count: 0


        enqueue: deferred (action, object) -> 

            #
            # * Insert objects onto the pending queue
            #

            return action.reject(
                new Error 'dinkum queue overflow (use config.queueLimit)'
                ) if queue.pending.count == config.queueLimit

            object.sequence = ++queue.sequence
                
            queue.pending.items[ (queue.sequence).toString() ] = object
            queue.pending.count++
            action.resolve()


        dequeue: deferred (action) -> 

            #
            # * Move n objects onto the active queue according to 
            #   predfined requestLimit
            #

            process.nextTick -> 

                return action.resolve [] if queue.suspended 

                slots = config.requestLimit - queue.active.count
                action.resolve( 

                    ( 
                        for seq of queue.redo.items
                            break if --slots < 0
                            object = queue.redo.items[seq]
                            queue.active.items[seq] = object
                            delete queue.redo.items[seq]
                            queue.active.count++
                            queue.redo.count--
                            object 

                    ).concat(

                        for seq of queue.pending.items 
                            break if --slots < 0
                            object = queue.pending.items[seq]
                            queue.active.items[seq] = object
                            delete queue.pending.items[seq]
                            queue.active.count++
                            queue.pending.count--
                            object

                    )
                )

        requeue: deferred (action, object) ->

            try
                seq = object.sequence.toString()
                queue.redo.items[seq] = object
                queue.redo.count++
                delete queue.active.items[seq]
                queue.active.count--
                action.resolve()
            catch error
                action.reject error


        update: deferred (action, state, object) -> 

            try switch state

                when 'done'

                    seq = object.sequence.toString()
                    if queue.active.items[seq]?
                        queue.active.count--
                        delete queue.active.items[seq]
                        queue.finished.count++
                    action.resolve()
                    queue.emitter.emit 'object::done'
                    return

                else action.resolve()

            catch error

                action.reject error


        stats: deferred (action) ->

            action.resolve 
                pending: 
                    count: queue.pending.count
                active:
                    count: queue.active.count
                done: 
                    count: queue.finished.count

    #
    # only the latest instance is accessable to test
    #

    testable = queue

    api = 

        enqueue: queue.enqueue
        dequeue: queue.dequeue
        requeue: queue.requeue
        update:  queue.update
        stats:   queue.stats

        #
        # TODO: may need to export emitter.otherApiBits('too')
        #
        # on: queue.emitter.on
        on: (event, handler) -> queue.emitter.on event, handler


    Object.defineProperty api, 'suspend', 
        get: -> queue.suspended = true

    Object.defineProperty api, 'resume', 
        get: -> queue.suspended = false

