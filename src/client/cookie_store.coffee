exports.create = (config = {}) ->

    config.hostname ||= 'localhost' 

    # throw new Error( 

    #     'CookieStore.create(config) requires config.hostname'

    # ) unless config.hostname?

    #
    # store factory initialized with hostname to allow
    # persistance later
    #

    return store = 

        cookies: {}

        setCookie: (cookies) -> 

            store.cookies[cookie] = Date.now() for cookie in cookies

        getCookie: -> 

            cookieString = ''       
            for cookie of store.cookies
                try 
                    pair = cookie.match(/(.*?);/)[1]

                    #
                    # TODO: - pass request context into this fn
                    #       - use it to filter for cookies to be sent
                    #         according to expiry, path, httponly, etc
                    #       - remove expired cookies
                    #

                    cookieString += pair + '; '

            return undefined unless cookieString
            return cookieString[0..-2]
