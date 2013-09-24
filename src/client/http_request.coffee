module.exports = class HttpReuquest

    constructor: (@promised, @opts) -> 

        #@error   = undefined
        sequence = undefined
        onDone   = undefined

        local =
            state: 
                value: 'pending'
                at: Date.now()
            

        Object.defineProperty this, 'sequence', 
            enumerable: true
            get: -> sequence
            set: (value) -> 
                return if sequence?
                return unless typeof value is 'number'
                sequence = value

        Object.defineProperty this, 'state', 
            enumerable: true
            get: -> local.state.value
            set: (value) => 
                local.state.value = value
                local.state.at = Date.now()
                switch value
                    when 'done' then onDone @error, this #DONE

        Object.defineProperty this, 'stateAt', 
            enumerable: true
            get: -> local.state.at
