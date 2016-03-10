C  = require \./collection
Hv = require \./model/hive .instance

is-loaded = false

module.exports =
  fetch-all: (success, fail) ->
    return success! if is-loaded
    $.when(
      C.Evidences.fetch!
      C.Edges.fetch!
      C.Nodes.fetch!
      C.Notes.fetch!
    ).then ok, error

    function ok
      is-loaded := true
      success!

    function error coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      fail! if fail?

  fetch-core: (success, fail) ->
    $.when(
      C.Maps.fetch!
      C.Users.fetch!
      Hv.Evidences.fetch! # dead evidences
      Hv.Map.fetch!
    ).then success, fail
