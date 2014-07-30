Bh  = require \backbone .history
C   = require \../collection
Hi  = require \../hive
R   = require \../router
V   = require \../view
Vme = require \./map/edit

module.exports = me =
  fetch-entities: (ok, fail) ->
    $.when(
      C.Evidences.fetch!
      C.Edges.fetch!
      C.Nodes.fetch!
      C.Notes.fetch!
      Hi.Evidences.fetch! # dead evidences
    ).then init, fail

    function init
      Vme.init!
      ok!

  on-signin: ->
    me.fetch-entities ok, fail

    function ok
      delete V.map.map # remove readonly map
      R.navigate \session, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      Bh.history.back!
