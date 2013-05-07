B = require \backbone
C = require \./collection
V = require \./view

exports.init = (router) ->
  V
    ..edge-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed,     -> navigate \edges
      ..on \rendered , (e) -> V.edge-a-node-sel.render C.Nodes, \name, e.get \a_node_id
      ..on \rendered , (e) -> V.edge-b-node-sel.render C.Nodes, \name, e.get \b_node_id
      ..on \saved    , (e) -> navigate "edge-info/#{e.id}"
    ..edge-evidence-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed, (e) -> navigate "edge-info/#{e.get \entity_id}"
      ..on \saved    , (e) -> navigate "edge-info/#{e.get \entity_id}"
    ..node-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed,     -> navigate \nodes
      ..on \rendered , (n) -> $ \#name .typeahead source:C.Nodes.pluck \name
      ..on \saved    , (n) -> navigate "node-info/#{n.id}"
    ..node-evidence-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed, (e) -> navigate "node-info/#{e.get \entity_id}"
      ..on \saved    , (e) -> navigate "node-info/#{e.get \entity_id}"
    ..note-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed,     -> B.history.history.back!
      ..on \saved    , (n) -> navigate "node-info/#{n.get \entity_id}"
    ..user-edit
      ..on \cancelled,     -> B.history.history.back!
      ..on \destroyed,     -> navigate \users
      ..on \saved    , (u) -> navigate "user-info/#{u.id}"
    ..user-signin
      ..on \cancelled,     -> B.history.history.back!
      ..on \saved    ,     -> navigate \session-info
    ..user-signup
      ..on \cancelled,     -> B.history.history.back!
      ..on \saved    ,     -> navigate \session-info

  function navigate route then router.navigate route, trigger:true
