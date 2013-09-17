{extend, promised} = require '../support'

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


        enqueue: promised (action, object) -> 

            return action.reject(
                new Error 'dinkum queue overflow'
                ) if queue.pending.count == config.queueLimit

            queue.pending.items[ (++queue.sequence).toString() ] = object
            queue.pending.count++
            action.resolve()


        dequeue: promised (action) -> 

            slots = config.rateLimit - queue.active.count
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
        

        queue: stats: promised (action) ->

            action.resolve 
                pending: 
                    count: queue.pending.count
                active:
                    count: queue.active.count


    return api = 

        enqueue: queue.enqueue
        dequeue: queue.dequeue
        queue:   queue.queue
