{extend} = require '../support'

queue = undefined
exports.testable = -> queue

exports.queue = (config) -> 

    queue = 

        sequence: 0
        queued: 
            count: 0
            items: {}


        enqueue: (object) -> 

            queue.queued.items[ (++queue.sequence).toString() ] = object: object
            queue.queued.count++

    return api = 

        enqueue: queue.enqueue

