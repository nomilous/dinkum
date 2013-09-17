{extend}    = require '../support'
{defer}     = require 'when'
{requestor} = require './requestor'

client = undefined
exports.testable = -> client

exports.client = extend requestor, (superclass, config) -> 

    client = 

        get: (opts = {}, result = defer()) -> 

            


    return api = 

        get: client.get