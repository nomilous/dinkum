module.exports = (superFn, fn = {}) -> 

    unless typeof fn is 'function'

        object = fn
        object[property] ||= superFn[property] for property of superFn
        return object
    
    return -> 

        object = fn.apply this, arguments
        object[property] ||= superFn[property] for property of superFn
        return object
