module.exports = (superFn, fn) -> (args...) -> 

        superclass = 

            if typeof superFn isnt 'function' then superFn
            else superFn.apply this, args

        # superclass ||= {}

        object = fn.apply this, [superclass].concat args
        
        # object ||= {}

        return object
