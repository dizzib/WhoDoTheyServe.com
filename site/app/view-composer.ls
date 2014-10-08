C  = require \./collection
E  = require \./entities
H  = require \./helper
Hs = require \./history
Ma = require \./map
M  = require \./model
S  = require \./session
V  = require \./view
D  = require \./view-directive

module.exports =
  edge: (id, act, child-id) ->
    edge <- fetch-entity C.Edges, id, \connection
    V.edge.render edge, D.edge
    V.meta.render edge, D.meta
    render-evidences id, act, child-id
    render-notes id, act
    Hs.set-edge edge
  edges: ->
    <- Ma.fetch-default # try to show at least edges of default map
    V.edges-head.render!
    V.edges.render C.Edges, D.edges
  map: ->
    function show m
      if is-sel-changed
        V.map.render!
        V.map-toolbar.reset!
        V.navbar.render!
      V.map.show!
      V.map-toolbar.show!
      V.map-info.render m, D.map
      V.map-meta.render m, D.meta
      V.map-meta.$el.find \.timeago .timeago! # async .view.finalize timeago runs too soon!
      return unless m.get-is-editable!
      return V.map-edit.render m, C.Maps, fetch:no
      V.map-edit.show!
    is-sel-changed = (not (m = V.map.map)? and not it?) or it isnt m?id
    return show m if not is-sel-changed
    err, m <- Ma.fetch it
    return H.show-error err if err
    show V.map.map = m
  node: (id, act, child-id) ->
    node <- fetch-entity C.Nodes, id, \actor
    V.node.render node, D.node
    V.node-edges-head.render!
    V.node-edges-a.render (C.Edges.find -> id is it.get \a_node_id), D.edges
    V.node-edges-b.render (C.Edges.find -> id is it.get \b_node_id), D.edges
    V.meta.render node, D.meta
    render-evidences id, act, child-id
    render-notes id, act
    Hs.set-node-id id
  nodes: ->
    <- Ma.fetch-default # try to show at least nodes of default map
    V.nodes-head.render!
    V.nodes.render C.Nodes, D.nodes
  user: ->
    V.user.render user = C.Users.get(id = it or C.Sessions.models.0?id), D.user
    V.meta.render user, D.meta
    <- E.fetch-all # all entities must be loaded for subsequent filtering
    render-user-entities id, V.maps, C.Maps, D.map
    render-user-entities id, V.edges, C.Edges, D.edges
    render-user-entities id, V.evidences, C.Evidences, D.user-evidences
    render-user-entities id, V.nodes, C.Nodes, D.nodes
    render-user-entities id, V.notes, C.Notes, D.user-notes
  users: ->
    V.users-head.render!
    V.users.render C.Users, D.users

## helpers

function fetch-entity coll, id, name, cb
  return cb ent if ent = coll.get id
  <- E.fetch-all # entity isn't in global cache so refresh gc and try again
  return H.show-error "Unable to render non-existant #name (#id)" unless ent = coll.get id
  cb ent
  V.finalise! # post-route invocation may have run before fetch-all, so invoke again to be sure

function render-evidences entity-id, act, id
  evs = C.Evidences.find -> entity-id is it.get \entity_id
  ev = C.Evidences.get id if act is \evi-edit
  ev = M.Evidence.create!set \entity_id, entity-id if act is \evi-new
  V.evidences-head.render void, D.evidences-head
  V.evidence-edit.render ev, C.Evidences, fetch:no if ev
  V.evidences.render evs, D.evidences unless act is \evi-new

function render-notes entity-id, act
  notes = C.Notes.find -> entity-id is it.get \entity_id
  note-by-signin =
    if act is \note-new then M.Note.create!set \entity_id, entity-id
    else notes.find(-> S.is-signed-in it.get \meta.create_user_id).models?0
  V.notes-head.render note-by-signin, D.notes-head
  V.note-edit.render note-by-signin, C.Notes, fetch:no if act in <[ note-edit note-new ]>
  V.notes.render notes, D.notes

function render-user-entities user-id, view, coll, directive then
  view.render (coll.find -> user-id is it.get \meta.create_user_id), directive
