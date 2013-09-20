{deferred} = require '../support'

queue = undefined
exports.testable = -> queue

exports.queue = (config = {}) -> 

    queue = 

        sequence: 0
        pending: 
            count: 0
            items: {}
        active:
            count: 0
            items: {}
        done: 
            count: 0


        enqueue: deferred (action, object) -> 

            #
            # * Insert objects onto the pending queue
            #

            return action.reject(
                new Error 'dinkum queue overflow'
                ) if queue.pending.count == config.queueLimit

            try console.log queue: object.opts.path

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

                slots = config.requestLimit - queue.active.count
                action.resolve( 

                    for seq of queue.pending.items

                        break if --slots < 0

                        object = queue.pending.items[seq]
                        queue.active.items[seq] = object
                        delete queue.pending.items[seq]
                        queue.active.count++
                        queue.pending.count--
                        object
                )
        

        queue: stats: deferred (action) ->

            action.resolve 
                pending: 
                    count: queue.pending.count
                active:
                    count: queue.active.count


    return api = 

        enqueue: queue.enqueue
        dequeue: queue.dequeue
        queue:   queue.queue
