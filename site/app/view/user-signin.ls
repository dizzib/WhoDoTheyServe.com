Bh  = require \backbone .history
C   = require \../collection
E   = require \../entities
Hi  = require \../hive
R   = require \../router
V   = require \../view
Vme = require \./map/edit

module.exports = me =
  init: ->
    Vme.init!
    # multi-select can't be browserified 'cos it references an adjacent png
    yepnope.injectCss \/lib-3p/multiple-select.css

  on-signin: ->
    E.fetch ok, fail

    function ok
      delete V.map.map # remove readonly map
      me.init!
      R.navigate \session, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      Bh.history.back!
