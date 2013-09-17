{testable, client} = require '../../lib/client/client'

console.log client: client()
console.log testable()

describe 'Client', ->

    context 'session', -> 

        context 'authentication', ->
        context 'cookies', -> 

    context 'status', -> 

        context 'active', -> 
        context 'pending', -> 

    context 'core methods', -> 

        context 'GET', -> 

            it 'returns the promise that the request will be sent'
            it 'accepts as agrument the promise of a result'
            it 'will generate a new result promise if not provided'

        context 'HEAD', -> 
        context 'POST', -> 
        context 'PUT', ->
        context 'DELETE', ->

    context 'extended methods', ->

        context 'TRACE', ->
        context 'OPTIONS', ->
        context 'CONNECT', ->
        context 'PATCH', -> 

