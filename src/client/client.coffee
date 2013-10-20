{enclose, deferred} = require 'also'
{RequestFilter}     = require '../support'
{defer}     = require 'when'
{Requestor} = require './requestor'

testable = undefined
exports._client = -> testable

exports.Client = enclose Requestor, (requestor, config = {}) -> 

    client = 

        requestor: requestor # testability


        get: RequestFilter config, (opts, result = defer()) -> 
            opts.method = 'GET'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        post: RequestFilter config, (opts, result = defer()) ->
            opts.method = 'POST'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        put: RequestFilter config, (opts, result = defer()) ->
            opts.method = 'PUT'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        delete: RequestFilter config, (opts, result = defer()) ->
            opts.method = 'DELETE'
            requestor.request(opts, result).then(
                -> 
                result.error
                result.notify
            )
            result.promise


        stats: deferred (action) -> 

            {resolve, reject, notify} = action
            requestor.stats().then resolve, reject, notify

        # queued: deferred (action) -> 
        #     action.resolve {}

        warnings: deferred (action) -> 

            action.resolve {}

        errors: deferred (action) -> 

            action.resolve {}

        config: deferred (action) -> 

            action.resolve {}



    client.stats.$$notable    = {}
    client.warnings.$$notable = {}
    client.errors.$$notable   = {}
    client.config.$$notable   = {}



    #
    # only the latest instance is accessable to test
    #

    testable = client

    return api = 

        get:       client.get
        post:      client.post
        put:       client.put
        delete:    client.delete
        stats:     client.stats
        warnings:  client.warnings
        errors:    client.errors
        config:    client.config
