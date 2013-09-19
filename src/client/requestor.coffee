{extend, promised} = require '../support'
{queue}            = require './queue'
{transport}        = require './transport'
HttpRequest        = require './http_request'
sequence           = require 'when/sequence'
parallel           = require 'when/parallel'

count = 0
requestor = undefined
exports.testable = -> requestor

exports.requestor = extend queue, (superclass, config = {}) -> 

    requestor = 

        superclass: superclass # testability

        transport: transport config

        request: promised (action, opts, deferral) -> 

            {resolve, reject, notify} = action

            sequence([

                #
                # * enqueue the new HttpRequest with options and the 
                #   deferral of promised result
                # 

                -> superclass.enqueue new HttpRequest deferral, opts
                        
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

                        do (request) -> -> requestor.transport.request request

                    ).then resolve, reject, notify

                reject
                notify

            )


    return api =

        request: requestor.request
