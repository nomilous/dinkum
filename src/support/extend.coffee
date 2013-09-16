module.exports = (superFn, fn = {}) -> 

    unless typeof fn is 'function'

        object = fn
        object[property] ||= superFn[property] for property of superFn
        return object
    
    return (args...) -> 

        superclass = 
            if typeof superFn isnt 'function' then superFn
            else superFn.apply this, args
        superclass ||= {}

        object = fn.apply this, [superclass].concat args
        object ||= {}
        #
        # TODO: perhaps make this optional by config
        # 
        #       it enables external access to the superclass 
        #       properties and functions
        #
        #object[property] ||= superclass[property] for property of superclass
        #
        return object
