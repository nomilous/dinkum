{enclose, deferred}   = require '../support'
{defer}     = require 'when'
{Requestor} = require './requestor'

testable = undefined
exports._client = -> testable

exports.Client = enclose Requestor, (requestor, config) -> 

    client = 

        requestor: requestor # testability

        get: (opts, result = defer()) -> 

            opts.method = 'GET'
            
            requestor.request( opts, result ).then(
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

        get: client.get
        stats: client.stats
