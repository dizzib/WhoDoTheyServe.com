B = require \backbone
C = require \./collection
H = require \./helper
V = require \./view

exports.init = (router) ->
  V
    ..edge-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> navigate \edges
      ..on \rendered , -> V.edge-a-node-sel.render C.Nodes, \name, it.get \a_node_id
      ..on \rendered , -> V.edge-b-node-sel.render C.Nodes, \name, it.get \b_node_id
      ..on \saved    , -> navigate "edge/#{it.id}"
    ..evidence-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> B.history.history.back!
      ..on \saved    , -> navigate B.history.fragment.replace /\/evi-.*$/g, ''
    ..node-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> navigate \nodes
      ..on \rendered , -> $ \#name .typeahead source:C.Nodes.pluck \name
      ..on \saved    , -> navigate "node/#{it.id}"
    ..note-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> B.history.history.back!
      ..on \saved    , -> navigate B.history.fragment.replace /\/note-.*$/g, ''
    ..user-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> navigate \users
      ..on \saved    , -> navigate "user/#{it.id}"
    ..user-signin
      ..on \cancelled, -> B.history.history.back!
      ..on \saved    , -> navigate \session
    ..user-signout
      ..on \destroyed, -> navigate \session
    ..user-signup
      ..on \cancelled, -> B.history.history.back!
      ..on \saved    , -> navigate \session

  function navigate route then router.navigate route, trigger:true
