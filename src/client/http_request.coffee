seq = 0

module.exports = class HttpReuquest

    constructor: (@deferral, @opts, @sequence = ++seq) -> 
