{deferred}    = require '../support'
HttpRequest = require './http_request'

testable = undefined
exports._authenticator = -> testable

exports.Authenticator = (config, queue) -> 

    config ||= {}

    authenticator = 

        queue: queue

        authenticating: 0

        configured: ->

            config.authenticator?

        authenticate: deferred (action, httpRequest) -> 

            unless authenticator.configured()

                error = new Error 'dinkum absence of authenticator config'
                error.detail = httpRequest.opts
                httpRequest.promised.reject error
                action.reject()
                return

            authenticator.authenticating = httpRequest.sequence
            action.resolve new HttpRequest
    
    #
    # only the latest instance is accessable to test
    #

    testable = authenticator

    return api = 

        authenticate: authenticator.authenticate
