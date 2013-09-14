dinkum = require '../lib/dinkum'
should = require 'should'

describe 'dinkum', -> 

    it 'exports BasicAuth', -> 

        should.exist dinkum.client.BasicAuth

    it 'exports CookieStore', -> 

        should.exist dinkum.client.CookieStore
