{defer} = require 'when'

module.exports = (fn) -> (args...) -> 

    promised = defer()
    fn.apply this, [promised].concat args
    promised.promise