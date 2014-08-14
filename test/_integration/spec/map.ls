H = require \./helper

module.exports.get-spec = (...args) ->
  h = H \map, ...args

  a: h.get-spec \a, name:'Map a' nodes:<[ a ]> default:true
  b: h.get-spec \b, name:'Map b' nodes:<[ b ]>
  c: h.get-spec \c, name:'Map c' nodes:<[ c ]>
