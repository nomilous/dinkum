
filters = 

    json: (opts) -> 

        console.log WITH_JSON: opts


module.exports = (fn) -> (opts, more...) -> 

    if opts.json? then filters.json opts

    fn.apply this, arguments


module.exports.filters = filters
