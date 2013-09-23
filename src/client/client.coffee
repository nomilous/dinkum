{enclose, deferred}   = require '../support'
{defer}     = require 'when'
{requestor} = require './requestor'

client = undefined
exports.testable = -> client

exports.client = enclose requestor, (superclass, config) -> 

    client = 

        superclass: superclass # testability

        get: (opts, result = defer()) -> 

            opts.method = 'GET'
            
            superclass.request( opts, result ).then(
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
