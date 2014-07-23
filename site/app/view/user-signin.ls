Bh  = require \backbone .history
C   = require \../collection
M   = require \../model
R   = require \../router
V   = require \../view
Vme = require \./graph/edit

module.exports = me =
  fetch-entities: (ok, fail) ->
    $.when(
      C.Evidences.fetch!
      C.Edges.fetch!
      C.Nodes.fetch!
      C.Notes.fetch!
      M.Hive.Evidences.fetch! # dead evidences
    ).then init, fail

    function init
      Vme.init!
      ok!

  on-signin: ->
    me.fetch-entities ok, fail

    function ok
      delete V.graph.map # remove readonly map
      R.navigate \session, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      Bh.history.back!