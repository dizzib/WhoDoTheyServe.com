_  = require \lodash
H  = require \./helper
R  = require \../helper .run
ST = require \../state

module.exports.get-spec = (...args) ->
  h = H \map ...args

  function get-spec key, fields
    const TYPES = <[ edges evidences nodes notes ]>
    fields.description ?= ''
    fields.name ?= "Map #key"
    (h.get-spec key, fields) <<< entities:
      {[t, {["is#n" get-spec-ents key, t, n] for n from 0 to 9}] for t in TYPES}

  function get-spec-ents key, type, n
    info: "map #key entities.#type length is #n"
    fn  : R -> ST.maps[key].entities[type].length.should.equal n

  a0: get-spec \a0 description:"123!&',()" nodes:<[ a ]>
  a1: get-spec \a1 nodes:<[ a ]>
  ax: _.extend do
    get-spec \ax nodes:<[ a ]> flags: private:true
    toggle-private: get-spec \ax flags: private:true
  b0: get-spec \b0 nodes:<[ b ]>
  c0: get-spec \c0 name:"C's map" nodes:<[ a b c d g ]>
  cx: get-spec \cx nodes:<[ g ]> flags: private:true
  list: {["is#n" h.get-spec-list n] for n in [0 to 5]}
