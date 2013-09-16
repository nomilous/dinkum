{extend} = require '../support'

queue = undefined
exports.testable = -> queue

exports.create = (config) -> 

    queue = 

        sequence: 0
        queued: {}
        enqueue: (object) -> 

            queue.queued[ (++queue.sequence).toString() ] = object: object

    return api = 

        enqueue: queue.enqueue