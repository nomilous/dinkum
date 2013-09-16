{extend}    = require '../support'
{requestor} = require './requestor'

client = undefined
exports.testable = -> client

exports.client = extend requestor, (superclass, config) -> 

    client = 

        get: ->


    return api = 

        get: client.get