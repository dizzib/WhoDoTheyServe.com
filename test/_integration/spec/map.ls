_  = require \lodash
H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map, ...args

  a: h.get-spec \a, name:'Map a' description:"a's map" nodes:<[ a ]> default:true
  b: h.get-spec \b, name:'Map b' description:"b's map" nodes:<[ b ]>
  c: _.extend do
    h.get-spec \c, name:"c's map" description:'' nodes:<[ a b c d g ]>
    entities:
      edges:
        is1: get-spec-edges \c, 1
        is2: get-spec-edges \c, 2
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2

function get-spec-edges key, n
  info: "map #key entities.edges length is #n"
  fn  : R -> ST.maps[key].entities.edges.length.should.equal n
