{extend, promised} = require '../support'
{queue}            = require './queue'
{transport}        = require './transport'
sequence           = require 'when/sequence'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    requestor = 

        superclass: superclass # testability

        transport: transport config

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
                    # * send all dequeued requests
                    #

                    console.log 
                        SEND: requests
                        WITH: requestor.transport

                    action.resolve()

                action.reject
                action.notify

            )


    return api =

        request: requestor.request
