{extend, defers} = require '../support'

queue = undefined
exports.testable = -> queue

exports.queue = (config) -> 

    queue = 

        sequence: 0
        pending: 
            count: 0
            items: {}
        active:
            count: 0
            items: {}


        enqueue: defers (promised, object) -> 

            queue.pending.items[ (++queue.sequence).toString() ] = object: object
            queue.pending.count++
            promised.resolve()

        dequeue: -> 

            for seq of queue.pending.items
                queue.active.items[seq] = queue.pending.items[seq]
                delete queue.pending.items[seq]
                queue.active.count++
                queue.pending.count--
                break

    return api = 

        enqueue: queue.enqueue
        dequeue: queue.dequeue
