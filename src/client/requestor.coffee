{extend, promised} = require '../support'
{queue}  = require './queue'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    config.transport ||= 'https'

    requestor = 

        superclass: superclass # testability

        request: promised (action) -> 

            superclass.enqueue().then -> 

                action.resolve()

    return api =

        request: requestor.request
