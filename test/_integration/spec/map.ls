H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map ...args

  function get-spec key, fields
    (h.get-spec key, fields) <<< entities:
      edges: {["is#i" get-spec-edges key, i] for i in [0 to 5]}

  function get-spec-edges key, n
    info: "map #key entities.edges length is #n"
    fn  : R -> ST.maps[key].entities.edges.length.should.equal n

  a0: get-spec \a0 name:'Map a0' description:"Map a0 123!&',()" nodes:<[ a ]>
  a1: get-spec \a1 name:'Map a1' description:"Map a1" nodes:<[ a b ]>
  c0: get-spec \c0 name:"c's map" description:'' nodes:<[ a b c d g ]>
  list: {["is#i" h.get-spec-list i] for i in [0 to 3]}
