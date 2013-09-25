{enclose, deferred} = require 'also'
{Queue}            = require './queue'
{Transport}       = require './transport'
HttpRequest      = require './http_request'
CookieStore     = require './cookie_store'
sequence       = require 'when/sequence'
parallel      = require 'when/parallel'

testable = undefined
exports._requestor = -> testable

exports.Requestor = enclose Queue, (queue, config = {}) -> 

    #
    # cookies always enabled for now
    #

    cookies = CookieStore.create config

    requestor = 

        queue: queue # testability

        transport: Transport config, queue, cookies

        request: deferred (action, opts, promised) -> 

            try if opts.method == 'POST'

                console.log POST: opts.body

            {resolve, reject, notify} = action

            # newRequest = new HttpRequest promised, opts
            # newRequest.onDone = requestor.done

            sequence([

                #
                # * enqueue the new HttpRequest with options and the 
                #   externally promised response 
                # 

                -> queue.enqueue new HttpRequest promised, opts
                        
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


        doNext: deferred (action) -> 

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

                -> queue.dequeue()

            ]).then(

                ([requests]) -> 

                    parallel( for httpRequest in requests

                        do (httpRequest) -> -> requestor.transport.request httpRequest   

                    ).then resolve, reject, notify

                reject
                notify

            )


        stats: deferred (action) -> 

            {resolve, reject, notify} = action
            queue.stats().then resolve, reject, notify


    queue.on 'object::done', requestor.doNext


    #
    # only the latest instance is accessable to test
    #

    testable = requestor


    return api =

        request: requestor.request
        stats: requestor.stats
