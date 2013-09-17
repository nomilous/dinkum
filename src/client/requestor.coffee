{extend, promised} = require '../support'
{queue}  = require './queue'
sequence = require 'when/sequence'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    requestor = 

        superclass: superclass # testability

        request: promised (action, opts, result) -> 

            sequence([

                #
                # * enqueue the new request options and the 
                #   promise of a result
                # 

                -> superclass.enqueue

                        opts: opts
                        promise: result
                        
                #
                # * dequeue any previously accumulated requests 
                #   and send those
                # 
                # * this dequeue may include the request that 
                #   was just enqueued
                #

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
