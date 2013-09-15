exports.create = (opts) ->

    throw new Error( 

        'CookieStore.create(opts) requires opts.hostname'

    ) unless opts.hostname?

    #
    # keeping VERY simple for now
    # ---------------------------
    # 
    # * Operating under the assumption that the server will only ever 
    #   call set-cookie with the ENTIRE cookie set necessary to operate 
    #   as client to the site.
    # 
    # * Despite that assumption being potentially incorrect i am never
    #   the less storing cookies in an array that will be entirely over
    #   written with the contents from each call to set-cookie.
    # 
    # * This one is definately a case of learning while doing instead 
    #   of before.
    # 

    store = []

    setCookie: (cookies) -> store = cookies

    getCookie: -> 

        return unless store.length > 0

        store.map( (cookie) -> 

            try cookie.match(/(.*?);/)[1]

        ).join('; ') + ';'
