{extend, promised} = require '../support'
{queue}  = require './queue'
sequence = require 'when/sequence'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    config.transport ||= 'https'

    requestor = 

        superclass: superclass # testability

        request: promised (action, opts = {}) -> 

            sequence([

                -> superclass.enqueue opts: opts
                -> superclass.dequeue()
                

            ]).then(

                ([NULL, requests]) -> 

                    #
                    # TODO: send all requests
                    #

                    console.log SEND: requests

                    action.resolve()


                action.reject
                action.notify

            )


    return api =

        request: requestor.request
