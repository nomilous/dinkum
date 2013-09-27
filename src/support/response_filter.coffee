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

        try contentTypeHeader = contentType = httpResult.headers['content-type']
        if contentTypeHeader?
            try contentType = contentTypeHeader.match(/(.*?);/)[1]
            if localFilters[contentType]?
                localFilters[contentType] httpResult
