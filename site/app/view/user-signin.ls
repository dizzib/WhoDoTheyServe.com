Bh  = require \backbone .history
C   = require \../collection
M   = require \../model
R   = require \../router
V   = require \../view
Vme = require \./graph/edit

module.exports =
  on-signin: ->
    $.when(
      C.Evidences.fetch!
      C.Edges.fetch!
      C.Nodes.fetch!
      C.Notes.fetch!
      M.Hive.Evidences.fetch! # dead evidences
    ).then start, fail

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      Bh.history.back!

    function start
      delete V.graph.map # remove readonly map
      Vme.init!
      R.navigate \session, trigger:true
