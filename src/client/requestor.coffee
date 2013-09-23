{enclose, deferred} = require '../support'
{Queue}            = require './queue'
{transport}       = require './transport'
HttpRequest      = require './http_request'
sequence        = require 'when/sequence'
parallel       = require 'when/parallel'

count = 0
requestor = undefined
exports.testable = -> requestor

exports.Requestor = enclose Queue, (queue, config = {}) -> 

    requestor = 

        queue: queue # testability

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

                -> queue.enqueue newRequest
                        
                #
                # * dequeue any previously accumulated requests 
                #   and send those
                # 
                # * this dequeue may include the request that 
                #   was just enqueued
                #

                -> queue.dequeue()

                

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

                -> queue.done error, httpRequest
                -> queue.dequeue()

            ]).then(

                ([NULL, requests]) -> 

                    parallel( for httpRequest in requests

                        do (httpRequest) -> -> requestor.transport.request httpRequest   

                    ).then resolve, reject, notify

                reject
                notify

            )


        stats: deferred (action) -> 

            {resolve, reject, notify} = action
            queue.stats().then resolve, reject, notify



    return api =

        request: requestor.request
        stats: requestor.stats
