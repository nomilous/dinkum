CookieStore = require '../../lib/client/cookie_store'
should = require 'should'

describe 'CookieStore', -> 

    context 'create(config)', ->

        it 'requires config.hostname', (done) -> 

            try CookieStore.create {}
            catch error
                error.should.match /requires config.hostname/
                done() 

        it 'persists to a store of some kind' # later


    context '[set|get]Cookie()', -> 

        #
        # usually on response from server
        #

        it 'stores or retreives the cookie array', (done) -> 

            jar = CookieStore.create hostname: 'www.xxx.yyy.zzz'

            jar.setCookie [

                'outfit=birthday-suit; Expires=Tue, 16-Oct-1139 05:00:50 GMT;'
                'shoes=0; Path=../garden; HttpOnly;'

                                #
                                # first version is ignoring these presumably 
                                # cookie selection mechanisms 
                                #

            ]

            jar.getCookie().should.equal 'outfit=birthday-suit; shoes=0;'
            done()

        it 'returns undefined if no cookies', (done) -> 


            jar = CookieStore.create hostname: 'www.ww.w'
            should.not.exist jar.getCookie()
            done()
