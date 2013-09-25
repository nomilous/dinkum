{enclose, deferred} = require 'also'
{RequestFilter}     = require '../support'
{defer}     = require 'when'
{Requestor} = require './requestor'

testable = undefined
exports._client = -> testable

exports.Client = enclose Requestor, (requestor, config) -> 

    client = 

        requestor: requestor # testability


        get: RequestFilter (opts, result = defer()) -> 
            opts.method = 'GET'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        post: RequestFilter (opts, result = defer()) ->
            opts.method = 'POST'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        stats: deferred (action) -> 

            {resolve, reject, notify} = action
            requestor.stats().then resolve, reject, notify

    #
    # only the latest instance is accessable to test
    #

    testable = client

    return api = 

        get:   client.get
        post:  client.post
        stats: client.stats
