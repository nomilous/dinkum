module.exports = class HttpReuquest

    constructor: (@promised, @opts) -> 

        @error   = undefined
        sequence = undefined

        local =
            state: 
                value: 'pending'
                at: Date.now()

        Object.defineProperty this, 'sequence', 
            enumerable: true
            get: -> sequence
            set: (value) -> 
                return if sequence?
                return unless typeof value == 'number'
                sequence = value

        Object.defineProperty this, 'state', 
            enumerable: true
            get: -> local.state.value
            set: (value) -> 
                local.state.value = value
                local.state.at = Date.now()

        Object.defineProperty this, 'stateAt', 
            enumerable: true
            get: -> local.state.at
