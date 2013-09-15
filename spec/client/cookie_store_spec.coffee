CookieStore = require '../../lib/client/cookie_store'
should = require 'should'

describe 'CookieStore', -> 

    context 'create(opts)', ->

        it 'requires opts.hostname', (done) -> 

            try CookieStore.create {}
            catch error
                error.should.match /requires opts.hostname/
                done() 

        it 'persists to a store of some kind' # later


    context 'setCookie(array)', -> 

        #
        # usually on response from server
        #

        it 'stores the response cookie array'





    context 'getCookie()', -> 

        #
        # usually preceding request to server
        #

        it 'gets the request cookie string'

