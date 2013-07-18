B = require \backbone
_ = require \underscore
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
      ..on \rendered , -> $ \#how .typeahead source:_.uniq C.Edges.pluck \how
      ..on \saved    , -> nav-entity-saved \edge, &0, &1
    ..evidence-edit
      ..on \cancelled, -> nav-extra-done \evi
      ..on \destroyed, -> nav-extra-done \evi
      ..on \saved    , -> nav-extra-done \evi
    ..node-edit
      ..on \cancelled, -> B.history.history.back!
      ..on \destroyed, -> navigate \nodes
      ..on \rendered , -> $ \#name .typeahead source:C.Nodes.pluck \name
      ..on \saved    , -> nav-entity-saved \node, &0, &1
    ..note-edit
      ..on \cancelled, -> nav-extra-done \note
      ..on \destroyed, -> nav-extra-done \note
      ..on \saved    , -> nav-extra-done \note
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

  function nav-entity-saved name, entity, is-new then
    H.log name, entity, is-new
    navigate "#{name}/#{entity.id}#{if is-new then '/evi-new' else ''}"

  function nav-extra-done name then
    navigate B.history.fragment.replace new RegExp("/#{name}-.*$", \g), ''
