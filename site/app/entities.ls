C  = require \./collection
M  = require \./model
Hi = require \./hive

is-loaded = false

module.exports =
  fetch: (success, fail) ->
    log \fetch, is-loaded
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
    C.Edges.set (_.map o.edges, -> new M.Edge it), remove:false
    C.Evidences.set (_.map o.evidences, -> new M.Evidence it), remove:false
    C.Nodes.set (_.map o.nodes, -> new M.Node it), remove:false
    C.Notes.set (_.map o.notes, -> new M.Note it), remove:false
