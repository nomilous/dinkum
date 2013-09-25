
defaultFilters = 

    json: (opts) -> 

        #
        # ammend opts with the necessary bits to
        # post a json request
        #
        
        encoded = JSON.stringify opts.json
        opts.headers ||= {}
        opts.headers['content-length'] = encoded.length
        opts.headers['content-type'] = 'application/json'
        opts.body = encoded


module.exports = (config, fn) -> 

    localFilters = defaultFilters

    for type of config.content

        #
        # allows overrides from config.content to customise the
        # json serialization, eg. 
        #   
        #  curl -X POST -H 'Content-Type: application/json' \
        #       -d 'JSON{"theActual":"JSON"}' $URL
        #

        if config.content[type].encode?

            console.log config.content[type].encode

            localFilters[type] = config.content[type].encode

    return (opts, more...) -> 

        if opts.json? then localFilters.json opts

        #
        # todo: look for filters / opts.type
        #       on each request to support
        #       more than just json
        #

        fn.apply this, arguments


module.exports.filters = defaultFilters
