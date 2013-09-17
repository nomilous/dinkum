{extend, promised} = require '../support'
{queue}            = require './queue'
{transport}        = require './transport'
sequence           = require 'when/sequence'
parallel           = require 'when/parallel'

requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    requestor = 

        superclass: superclass # testability

        transport: transport config

        request: promised (action, opts, result) -> 

            {resolve, reject, notify} = action

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

                    parallel( for request in requests

                        do (request) -> 

                            {opts, promise} = request
                            -> requestor.transport.request opts, promise

                    ).then resolve, reject, notify

                reject
                notify

            )


    return api =

        request: requestor.request
