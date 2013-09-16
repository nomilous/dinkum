{extend} = require '../support'
{queue}  = require './queue'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config) -> 

    requestor = 

        superclass: superclass # testability

        request: -> 

            superclass.enqueue()


    return api =

        request: requestor.request
