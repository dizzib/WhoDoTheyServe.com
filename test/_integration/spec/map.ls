_  = require \lodash
H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map ...args

  a0: h.get-spec \a0 name:'Map a0' description:"Map a0 123!&',()" nodes:<[ a ]> default:true
  a1: _.extend do
    h.get-spec \a1 name:'Map a1' description:"Map a1" nodes:<[ a b ]>
    get-entities \a1
  c0: _.extend do
    h.get-spec \c0 name:"c's map" description:'' nodes:<[ a b c d g ]>
    get-entities \c0
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2
    is3: h.get-spec-list 3

function get-spec-edges key, n
  info: "map #key entities.edges length is #n"
  fn  : R -> ST.maps[key].entities.edges.length.should.equal n

function get-entities key
  entities:
    edges:
      is0: get-spec-edges key, 0
      is1: get-spec-edges key, 1
      is2: get-spec-edges key, 2
      is3: get-spec-edges key, 3
      is4: get-spec-edges key, 4
      is5: get-spec-edges key, 5
