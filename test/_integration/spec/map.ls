_  = require \lodash
H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map ...args

  function get-spec key, fields
    fields.description ?= ''
    fields.name ?= "Map #key"
    (h.get-spec key, fields) <<< entities:
      edges: {["is#i" get-spec-edges key, i] for i in [0 to 5]}

  function get-spec-edges key, n
    info: "map #key entities.edges length is #n"
    fn  : R -> ST.maps[key].entities.edges.length.should.equal n

  a0: get-spec \a0 description:"123!&',()" nodes:<[ a ]>
  a1: get-spec \a1 nodes:<[ a ]>
  ax: _.extend do
    get-spec \ax nodes:<[ a ]> flags: private:true
    private: get-spec \ax flags: private:true
  b0: get-spec \b0 nodes:<[ b ]>
  c0: get-spec \c0 name:"c's map" nodes:<[ a b c d g ]>
  cx: get-spec \cx nodes:<[ g ]> flags: private:true
  list: {["is#i" h.get-spec-list i] for i in [0 to 5]}
