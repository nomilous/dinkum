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


        done: (error, httpRequest) -> 

            console.log DONE: httpRequest.sequence

            #
            # * inform the queue of this request being done
            #

            #
            # * do another round of dequeueing
            #


    return api =

        request: requestor.request
