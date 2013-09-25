
defaultFilters = 
    
    json: (opts) -> 
        console.log WITH_JSON: opts


module.exports = (config, fn) -> 

    localFilters = defaultFilters
    for type of config.content
        localFilters[type] = config.content[type]

    return (opts, more...) -> 

        if opts.json? then localFilters.json opts

        #
        # todo: look for filters / opts.type
        #       on each request to support
        #       more than just json
        #

        fn.apply this, arguments


module.exports.filters = defaultFilters
