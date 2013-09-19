module.exports = class HttpReuquest

    constructor: (@promised, @opts) -> 

        sequence = undefined
        state    = value: 'pending'

        Object.defineProperty this, 'sequence', 
            enumerable: true
            get: -> sequence
            set: (value) -> 
                return if sequence?
                return unless typeof value == 'number'
                sequence = value

        Object.defineProperty this, 'state', 
            enumerable: true
            get: -> state.value

