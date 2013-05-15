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
  after: ->
    $ \.timeago .timeago!
    $ \.view .addClass \ready
  before: ->
    $ \.view>* .off!hide! # call off() so different views can use same element
    $ \.view .removeClass \editing
    $ \.view .removeClass \ready
    V.navigator.render!
  routes:
    ''                 : \home
    \doc/about         : \doc_about
    \edge/edit/:id     : \edge_edit
    \edge/new          : \edge_edit
    \edge/:id          : \edge
    \edge/:id/:act     : \edge
    \edge/:id/:act/:id : \edge
    \edges             : \edges
    \graph             : \graph
    \home              : \home
    \node/edit/:id     : \node_edit
    \node/new          : \node_edit
    \node/:id          : \node
    \node/:id/:act     : \node
    \node/:id/:act/:id : \node
    \nodes             : \nodes
    \session           : \session
    \user              : \user
    \user/edit/:id     : \user_edit
    \user/signin       : \user_signin
    \user/signout      : \user_signout
    \user/signup       : \user_signup
    \user/:id          : \user
    \users             : \user_list
  doc_about   : -> V.doc-about.render!
  graph       : -> V.graph.render!
  edge        : (id, act, child-id) ->
    V.edge.render (edge = C.Edges.get id), D.edge
    V.meta.render edge, D.meta
    render-evidences id, act, child-id
    render-notes     id, act
  edge_edit: -> V.edge-edit.render M.Edge.create(it), C.Edges
  edges    : ->
    V.edges-head.render!
    V.edges     .render C.Edges, D.edges
  home: -> V.home.render!
  node: (id, act, child-id) ->
    V.node           .render (node = C.Nodes.get id), D.node
    V.node-edges-head.render!
    V.node-edges-a   .render (C.Edges.find -> id is it.get \a_node_id), D.edges
    V.node-edges-b   .render (C.Edges.find -> id is it.get \b_node_id), D.edges
    V.meta           .render node, D.meta
    render-evidences id, act, child-id
    render-notes     id, act
  nodes: ->
    V.nodes-head.render!
    V.nodes.render C.Nodes, D.nodes
  node_edit  : -> V.node-edit.render M.Node.create(it), C.Nodes
  session    : -> V.session.render!
  user_edit  : -> V.user-edit.render M.User.create(it), C.Users
  user_list  : -> V.users.render C.Users, D.users
  user_signin: -> V.user-signin.render M.Session.create!, C.Sessions
  user_signup: -> V.user-signup.render M.Signup.create!, C.Users
  user       : ->
    V.user.render (C.Users.get(id = it or C.Sessions.models.0?id)), D.user
    render-user-entities id, V.edges    , C.Edges    , D.edges
    render-user-entities id, V.evidences, C.Evidences, D.user-evidences
    render-user-entities id, V.nodes    , C.Nodes    , D.nodes
    render-user-entities id, V.notes    , C.Notes    , D.user-notes
  user_signout: ->
    return navigate \session unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success: -> navigate \session
    function navigate route then module.exports.navigate route, trigger:true

module.exports = new Router!

function render-evidences entity-id, act, id then
  evs = C.Evidences.find -> entity-id is it.get \entity_id
  ev  = C.Evidences.get id if act is \evi-edit
  ev  = M.Evidence.create!set \entity_id, entity-id if act is \evi-new
  V.evidences-head.render void, D.evidences-head
  V.evidence-edit .render ev, C.Evidences, fetch:no if ev
  V.evidences     .render evs, D.evidences, void-view:V.evidences-void

function render-notes entity-id, act then
  notes = C.Notes.find -> entity-id is it.get \entity_id
  note-by-signin =
    if act is \note-new then M.Note.create!set \entity_id, entity-id
    else notes.find(-> S.is-signed-in it.get \meta.create_user_id).models?0
  V.notes-head.render note-by-signin, D.notes-head
  V.note-edit .render note-by-signin, C.Notes, fetch:no if act in <[ note-edit note-new ]>
  V.notes     .render notes, D.notes

function render-user-entities user-id, view, coll, directive then
  view.render (coll.find -> user-id is it.get \meta.create_user_id), directive
