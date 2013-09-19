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

            sequence([

                #
                # * enqueue the new HttpRequest with options and the 
                #   externally promised response 
                # 

                -> superclass.enqueue new HttpRequest promised, opts
                        
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

                        do (request) -> -> requestor.transport.request httpRequest

                    ).then resolve, reject, notify

                reject
                notify

            )


    return api =

        request: requestor.request
