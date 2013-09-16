module.exports = (superFn, fn = {}) -> 

    unless typeof fn is 'function'

        object = fn
        object[property] ||= superFn[property] for property of superFn
        return object
    
    return -> 

        superclass = 
            if typeof superFn isnt 'function' then superFn
            else superFn.apply this, arguments

        object = fn.apply this, arguments
        object[property] ||= superclass[property] for property of superclass
        return object
