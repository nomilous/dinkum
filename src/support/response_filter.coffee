defaultFilters = 

    'application/json': (httpResult) -> 

        decoded = JSON.parse httpResult.body
        httpResult.body = decoded


module.exports = (config) -> 

    localFilters = defaultFilters
    for type of config.content
        if config.content[type].decode?
            localFilters[type] = config.content[type].decode

    return (httpResult) -> 

        try contentType = httpResult.headers['content-type']
        if contentType? and localFilters[contentType]?
            localFilters[contentType] httpResult
