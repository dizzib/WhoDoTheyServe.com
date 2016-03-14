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
      edges    : {["is#i" get-spec-ents key, \edge, i] for i in [0 to 9]}
      evidences: {["is#i" get-spec-ents key, \evidence, i] for i in [0 to 9]}
      nodes    : {["is#i" get-spec-ents key, \node, i] for i in [0 to 9]}
      notes    : {["is#i" get-spec-ents key, \note, i] for i in [0 to 9]}

  function get-spec-ents key, type, n
    info: "map #key entities.#{type}s length is #n"
    fn  : R -> ST.maps[key].entities["#{type}s"].length.should.equal n

  a0: get-spec \a0 description:"123!&',()" nodes:<[ a ]>
  a1: get-spec \a1 nodes:<[ a ]>
  ax: _.extend do
    get-spec \ax nodes:<[ a ]> flags: private:true
    private: get-spec \ax flags: private:true
  b0: get-spec \b0 nodes:<[ b ]>
  c0: get-spec \c0 name:"C's map" nodes:<[ a b c d g ]>
  cx: get-spec \cx nodes:<[ g ]> flags: private:true
  list: {["is#i" h.get-spec-list i] for i in [0 to 5]}
