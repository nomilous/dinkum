module.exports = (superFn, fn = ->) -> 
    
    fn[property] ||= superFn[property] for property of superFn
    return fn
    
