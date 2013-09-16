{extend, promised} = require '../support'

queue = undefined
exports.testable = -> queue

exports.queue = (config = {}) -> 

    config.queueLimit ?= 100

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

            queue.pending.items[ (++queue.sequence).toString() ] = object: object
            queue.pending.count++
            action.resolve()

        dequeue: promised (action) -> 

            for seq of queue.pending.items
                queue.active.items[seq] = queue.pending.items[seq]
                delete queue.pending.items[seq]
                queue.active.count++
                queue.pending.count--
                action.resolve [queue.active.items[seq]]
                break

    return api = 

        enqueue: queue.enqueue
        dequeue: queue.dequeue
