B  = require \backbone
C  = require \../collection
Cs = require \../collections
Hv = require \../model/hive .instance
S  = require \../session
V  = require \../view
D  = require \./directive

M-Evi  = require \../model/evidence
M-Map  = require \../model/map
M-Note = require \../model/note

module.exports =
  edge: (id, act, child-id) ->
    done = arguments[*-1]
    fetch-entity C.Edges, id, \connection (edge) ->
      V.edge.render edge, D.edge
      V.meta.render edge, D.meta
      render-evidences id, act, child-id
      render-notes id, act
      B.tracker.edge = edge
      done!
    false # async done
  edges: (id) ->
    <- render-nodes-or-edges arguments[*-1]
    V.edges-head.render!
    V.edges.render C.Edges, D.edges
  map: (id) ->
    done = arguments[*-1]
    loc = B.history.fragment
    function show m
      return unless B.history.fragment is loc # bail if user navigated away
      V.map.map = m
      if is-sel-changed
        V.map.render!
        V.map-toolbar.reset!
        V.navbar.render!
      V.map.show!
      V.map-toolbar.show!
      V.map-info.render m, D.map
      V.map-meta.render m, D.meta
      return done! unless m.get-is-editable!
      V.map-edit.render m, C.Maps, fetch:no directive:D.map-edit
      V.map-edit.show!
      done!
    is-sel-changed = (not (m = V.map.map)? and not id?) or id isnt m?id
    return show m if not is-sel-changed
    return show M-Map.create! unless id?
    return B.trigger \error "Unable to get map #id" unless m = C.Maps.get id
    m.fetch success:show
    false # async done
  node: (id, act, child-id) ->
    done = arguments[*-1]
    fetch-entity C.Nodes, id, \actor (node) ->
      V.node.render node, D.node
      V.node-edges-head.render!
      V.node-edges-a.render (C.Edges.find -> id is it.get \a_node_id), D.edges
      V.node-edges-b.render (C.Edges.find -> id is it.get \b_node_id), D.edges
      V.meta.render node, D.meta
      render-evidences id, act, child-id
      render-notes id, act
      B.tracker.node-ids.push id
      done!
    false # async done
  nodes: (id) ->
    <- render-nodes-or-edges arguments[*-1]
    V.nodes-head.render!
    V.nodes.render C.Nodes, D.nodes
  user: (id) ->
    done = arguments[*-1]
    V.user.render user = C.Users.get(id ||= S.get-id!), D.user
    V.meta.render user, D.meta
    Cs.fetch-all -> # all entities must be loaded for subsequent filtering
      render-user-entities id, V.maps, C.Maps, D.map
      render-user-entities id, V.edges, C.Edges, D.edges
      render-user-entities id, V.evidences, C.Evidences, D.user-evidences
      render-user-entities id, V.nodes, C.Nodes, D.nodes
      render-user-entities id, V.notes, C.Notes, D.user-notes
      done!
    false # async done

## helpers

function fetch-entity coll, id, name, cb
  return cb ent if ent = coll.get id
  <- Cs.fetch-all # entity isn't in global cache so refresh gc and try again
  return B.trigger \error "Unable to render non-existant #name (#id)" unless ent = coll.get id
  cb ent

function render-nodes-or-edges done, render
  function refresh cb # at least show entities belonging to default map
    if m = C.Maps.get Hv.Map.default-id
      loc = B.history.fragment
      m.fetch success: ->
        # ideally we'd only render if the data has changed i.e. response code 200 not 304
        # Unfortunately there is no easy way to detect a 304.
        render! if B.history.fragment is loc # skip if user navigated away
        cb!
    else
      render!
      cb!
  if C.Nodes.length # render immediately then refresh in background
    render!
    refresh ->
    true # sync
  else # first time through we have nothing to render immediately
    refresh done
    false # async

function render-evidences entity-id, act, id
  evs = C.Evidences.find -> entity-id is it.get \entity_id
  ev = C.Evidences.get id if act is \evi-edit
  ev = M-Evi.create!set \entity_id entity-id if act is \evi-new
  V.evidences-head.render void D.evidences-head
  V.evidence-edit.render ev, C.Evidences, fetch:no if ev
  V.evidences.render evs, D.evidences unless act is \evi-new

function render-notes entity-id, act
  notes = C.Notes.find -> entity-id is it.get \entity_id
  note-by-signin =
    if act is \note-new then M-Note.create!set \entity_id entity-id
    else notes.find(-> S.is-signed-in it.get \meta.create_user_id).models?0
  V.notes-head.render note-by-signin, D.notes-head
  V.note-edit.render note-by-signin, C.Notes, fetch:no if act in <[ note-edit note-new ]>
  V.notes.render notes, D.notes

function render-user-entities user-id, view, coll, directive
  view.render (coll.find -> user-id is it.get \meta.create_user_id), directive
