defaultFilters = 

    'application/json': (opts) -> 

        #
        # ammend opts with the necessary bits to
        # post a json request
        #
        
        encoded = JSON.stringify opts['application/json']
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

            localFilters[type] = config.content[type].encode

    return (opts, more...) -> 

        if opts['application/json']? then localFilters['application/json'] opts

        else 

            for contentType of localFilters 

                #
                # for all configured content types (in created order)
                # ---------------------------------------------------
                # 
                # * if there is an object in the opts hash by the same 
                #   key then that is the payload
                # * pass to the corresponding encoder
                # 
                
                if opts[contentType]?
                    localFilters[contentType] opts
                    break

        fn.apply this, arguments


module.exports.filters = defaultFilters
