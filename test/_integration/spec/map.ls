_  = require \lodash
H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map ...args

  a: h.get-spec \a name:'Map a' description:"Map a 123!&',()" nodes:<[ a ]> default:true
  b: _.extend do
    h.get-spec \b name:'Map b' description:"Map b" nodes:<[ a b ]>
    get-entities \b
  c: _.extend do
    h.get-spec \c name:"c's map" description:'' nodes:<[ a b c d g ]>
    get-entities \c
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
