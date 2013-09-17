{extend}    = require '../support'
{defer}     = require 'when'
{requestor} = require './requestor'

client = undefined
exports.testable = -> client

exports.client = extend requestor, (superclass, config) -> 

    client = 

        superclass: superclass # testability

        get: (opts, result = defer()) -> 

            opts.method = 'GET'

            superclass.request opts, result


    return api = 

        get: client.get
