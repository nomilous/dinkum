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


        #
        # TODO: convert to also support node style callbacks
        #

        stats: deferred (action, opts, callback) -> 
            {resolve, reject, notify} = action
            requestor.stats().then( 
                (stats) -> 
                    if callback? then callback null, stats
                    resolve stats
                (error) -> 
                    if callback? then callback error
                    reject error
                notify
            )

        # queued: deferred (action) -> 
        #     action.resolve {}

        # warnings: deferred (action) -> 
        #     action.resolve fake: 'warnings'

        # errors: deferred (action) -> 
        #     action.resolve fake: 'errors'

        # config: deferred (action) -> 
        #     action.resolve fake: 'config'



    client.stats.$$notice = {}

    # client.warnings.$$notice = {}
    # client.errors.$$notice   = {}
    # client.config.$$notice   = {}


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
        # warnings:  client.warnings
        # errors:    client.errors
        # config:    client.config


