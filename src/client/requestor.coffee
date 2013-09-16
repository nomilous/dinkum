{extend} = require '../support'
{queue}  = require './queue'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config) -> 

    console.log superclass

    requestor = 

        request: -> 


    return api =

        request: requestor.request
