C  = require \./collection
M  = require \./model
Hi = require \./hive

is-loaded = false

module.exports =
  fetch: (success, fail) ->
    return success! if is-loaded
    $.when(
      C.Evidences.fetch!
      C.Edges.fetch!
      C.Nodes.fetch!
      C.Notes.fetch!
      Hi.Evidences.fetch! # dead evidences
    ).then done, fail or fail-default

    function done
      is-loaded := true
      success!

    function fail-default coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"

  merge: (o) ->
    C.Edges.set o.edges, remove:false
    C.Evidences.set o.evidences, remove:false
    C.Nodes.set o.nodes, remove:false
    C.Notes.set o.notes, remove:false
