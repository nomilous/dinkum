{defer} = require 'when'

module.exports = (fn) -> (args...) -> 

    action = defer()
    fn.apply this, [action].concat args
    action.promise
