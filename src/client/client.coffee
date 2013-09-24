{enclose, deferred}   = require '../support'
{defer}     = require 'when'
{Requestor} = require './requestor'

client = undefined
exports._client = -> client

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
            superclass.stats().then resolve, reject, notify


    return api = 

        get: client.get
        stats: client.stats
