B = require \backbone
H = require \./helper
C = require \./collection
M = require \./model
S = require \./session
V = require \./view
D = require \./view-directive

V.footer .render!
V.version.render!

Router = B.Router.extend do
  before: ->
    $ \.view>* .hide!
    $ \.view .removeClass \editing
    $ \.view .removeClass \hide-on-boot
    V.navigator.render!
  routes:
    ''                 : \graph
    \doc/about         : \doc_about
    \doc/api           : \doc_api
    \doc/disclaimer    : \doc_disclaim
    \edge/:id          : \edge
    \edge/:id/:act     : \edge
    \edge/:id/:act/:id : \edge
    \edge-edit/:id     : \edge_edit
    \edge-new          : \edge_edit
    \edges             : \edge_list
    \graph             : \graph
    \node/:id          : \node
    \node/:id/:act     : \node
    \node/:id/:act/:id : \node
    \node-edit/:id     : \node_edit
    \node-new          : \node_edit
    \nodes             : \node_list
    \session           : \session
    \user              : \user
    \user/:id          : \user
    \users             : \user_list
    \user-edit/:id     : \user_edit
    \user-signin       : \user_signin
    \user-signout      : \user_signout
    \user-signup       : \user_signup
  doc_about   : -> V.doc-about.render!
  doc_api     : -> V.doc-api.render!
  doc_disclaim: -> V.doc-disclaimer.render!
  graph       : -> V.graph.render!
  edge        : (id, act, child-id) ->
    V.edge.render (edge = C.Edges.get id), D.edge
    V.meta.render edge, D.meta
    C.Evidences id .fetch error:H.on-err, success: -> render-evidences it, id, act, child-id
    C.Notes     id .fetch error:H.on-err, success: -> render-notes     it, id, act
  edge_edit   : -> V.edge-edit.render M.Edge.create(it), C.Edges
  edge_list   : -> V.edges.render C.Edges, D.edges
  node        : (id, act, child-id) ->
    V.node           .render (node = C.Nodes.get id), D.node
    V.node-edges-head.render!
    V.node-edges-a   .render (C.Edges.find -> id is it.get \a_node_id), D.edges
    V.node-edges-b   .render (C.Edges.find -> id is it.get \b_node_id), D.edges
    V.meta           .render node, D.meta
    C.Evidences id .fetch error:H.on-err, success: -> render-evidences it, id, act, child-id
    C.Notes     id .fetch error:H.on-err, success: -> render-notes     it, id, act
  node_list   : -> V.nodes.render C.Nodes, D.nodes
  node_edit   : -> V.node-edit.render M.Node.create(it), C.Nodes
  session     : -> V.session.render!
  user_edit   : -> V.user-edit.render M.User.create(it), C.Users
  user_list   : -> V.users.render C.Users, D.users
  user_signin : -> V.user-signin.render M.Session.create!, C.Sessions
  user_signup : -> V.user-signup.render M.Signup.create!, C.Users
  user        : ->
    V.user      .render (C.Users.get(id = it or C.Sessions.models.0?id)), D.user
    V.user-edges.render (C.Edges.find -> id is it.get \meta.create_user_id), D.user-edges
    V.user-nodes.render (C.Nodes.find -> id is it.get \meta.create_user_id), D.user-nodes
  user_signout: ->
    return navigate \session unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success: -> navigate \session
    function navigate route then router.navigate route, trigger:true

module.exports = router = new Router!

function render-evidences evs, entity-id, act, id then
  ev = M.Evidence.create!set \entity_id, entity-id if act is \evi-new
  ev = evs.get id if act is \evi-edit
  V.evidences-head.render void, D.evidences-head
  V.evidence-edit .render ev, evs, fetch:no if ev
  V.evidences     .render evs, D.evidences, void-view:V.evidences-void

function render-notes notes, entity-id, act then
  note-by-signin = if act is \note-new then M.Note.create!set \entity_id, entity-id
    else notes.find(-> S.is-signed-in it.get \meta.create_user_id).models?0
  V.notes-head.render note-by-signin, D.notes-head
  V.note-edit .render note-by-signin, notes, fetch:no if act in <[ note-edit note-new ]>
  V.notes     .render notes, D.notes, fetch:no
