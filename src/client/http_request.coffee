module.exports = class HttpReuquest

    constructor: (@deferral, @opts) -> 

        sequence = undefined
        Object.defineProperty this, 'sequence', 
            enumerable: true
            get: -> sequence
            set: (value) -> 
                return if sequence?
                return unless typeof value == 'number'
                sequence = value

