{enclose}   = require '../support'
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


    return api = 

        get: client.get
