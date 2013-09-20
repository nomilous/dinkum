{enclose, deferred} = require '../support'
{queue}            = require './queue'
{transport}       = require './transport'
HttpRequest      = require './http_request'
sequence        = require 'when/sequence'
parallel       = require 'when/parallel'

count = 0
requestor = undefined
exports.testable = -> requestor

exports.requestor = enclose queue, (superclass, config = {}) -> 

    requestor = 

        superclass: superclass # testability

        transport: transport config

        request: deferred (action, opts, promised) -> 

            {resolve, reject, notify} = action

            newRequest = new HttpRequest promised, opts
            newRequest.onDone = requestor.done

            sequence([

                #
                # * enqueue the new HttpRequest with options and the 
                #   externally promised response 
                # 

                -> superclass.enqueue newRequest
                        
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

                    parallel( for httpRequest in requests

                        #
                        # https://github.com/nomilous/knowledge/blob/master/spec/promise/loops.coffee#L74
                        #

                        do (httpRequest) -> -> requestor.transport.request httpRequest

                    ).then resolve, reject, notify

                reject
                notify

            )


        done: deferred (action, error, httpRequest) -> 

            #
            # TODO: nothing is monitoring this promise 
            #

            {resolve, reject, notify} = action 

            #
            # a request has completed
            # -----------------------
            # 
            # * inform the queue to adjust accordingly
            # * get the next batch (probably only one) to send
            #

            sequence([

                -> superclass.done error, httpRequest
                -> superclass.dequeue()

            ]).then(

                ([NULL, requests]) -> 

                    console.log NEXT: requests

                    parallel( for httpRequest in requests

                        do (httpRequest) -> -> requestor.transport.request httpRequest   

                    ).then resolve, reject, notify

                reject
                notify

            )


    return api =

        request: requestor.request
