B = require \backbone
H = require \./helper
C = require \./collection
M = require \./model
V = require \./view
D = require \./view-directive

V.footer.render!
V.version.render!

Router = B.Router.extend do
  before: ->
    $ \.view>* .hide!
    $ \.view .removeClass \hide-on-boot
    V.navigator.render!
  routes:
    ''                      : \graph
    \about                  : \doc_about
    \api                    : \doc_api
    \disclaimer             : \doc_disclaim
    \edges                  : \edge_list
    \edge-edit/:id          : \edge_edit
    \edge-evi-del/:eid/:id  : \edge_evi_del
    \edge-evi-new/:id       : \edge_evi_new
    \edge-info/:id          : \edge_info
    \edge-new               : \edge_edit
    \graph                  : \graph
    \nodes                  : \node_list
    \node-edit/:id          : \node_edit
    \node-evi-del/:eid/:id  : \node_evi_del
    \node-evi-new/:id       : \node_evi_new
    \node-info/:id          : \node_info
    \node-new               : \node_edit
    \session-info           : \session_info
    \users                  : \user_list
    \user-edit/:id          : \user_edit
    \user-info              : \user_info
    \user-info/:id          : \user_info
    \user-signin            : \user_signin
    \user-signout           : \user_signout
    \user-signup            : \user_signup
  doc_about   : -> V.doc-about.render!
  doc_api     : -> V.doc-api.render!
  doc_disclaim: -> V.doc-disclaimer.render!
  graph       : -> V.graph.render!
  edge_evi_del:    get-renderer-evidence-del \edge-info
  edge_evi_new:    render-edge-evidence-new
  edge_edit   : -> V.edge-edit.render M.Edge.create(it), C.Edges
  edge_info   :    render-edge-info
  edge_list   :    -> V.edges.render C.Edges, D.edges
  node_list   :    -> V.nodes.render C.Nodes, D.nodes
  node_evi_del:    get-renderer-evidence-del \node-info
  node_evi_new:    render-node-evidence-new
  node_edit   : -> V.node-edit.render M.Node.create(it), C.Nodes
  node_info   :    render-node-info
  session_info: -> V.session-info.render!
  user_edit   : -> V.user-edit.render M.User.create(it), C.Users
  user_info   :    render-user-info
  user_list   : -> V.users.render C.Users, D.users
  user_signin : -> V.user-signin.render M.Session.create!, C.Sessions
  user_signup : -> V.user-signup.render M.Signup.create!, C.Users
  user_signout: -> signout!

module.exports = router = new Router!

function get-renderer-evidence-del info-url then (entity-id, id) ->
  return nav! unless confirm 'Are you sure you want to delete this evidence ?'
  C.Evidences entity-id .destroy id, success:nav, error:H.on-err
  function nav then navigate "#{info-url}/#{entity-id}"

function navigate route then router.navigate route, trigger:true

function render-edge-info then
  V.edge-info          .render (edge = C.Edges.get it), D.edge-info
  V.edge-evidences-head.render edge, D.edge-evidences-head
  V.edge-evidences     .render (C.Evidences it), D.edge-evidences, void-view:V.edge-evidences-void
  V.edge-meta          .render edge, D.meta

function render-edge-evidence-new then
  V.edge-info         .render (C.Edges.get it), D.edge-info
  V.edge-evidence-edit.render (M.Evidence.create!set \entity_id, it), C.Evidences it

function render-node-evidence-new then
  V.node-info         .render (C.Nodes.get it), D.node-info
  V.node-evidence-edit.render (M.Evidence.create!set \entity_id, it), C.Evidences it

function render-node-info then
  V.node-info          .render (node = C.Nodes.get id=it), D.node-info
  V.node-evidences-head.render node, D.node-evidences-head
  V.node-evidences     .render (C.Evidences id), D.node-evidences, void-view:V.node-evidences-void
  V.node-edges-head    .render node, D.node-edges-head
  V.node-edges-a       .render (C.Edges.find -> id is it.get \a_node_id), D.edges
  V.node-edges-b       .render (C.Edges.find -> id is it.get \b_node_id), D.edges
  V.node-meta          .render node, D.meta

function render-user-info then
  V.user-info .render (C.Users.get(id = it or C.Sessions.models.0?id)), D.user-info
  V.user-edges.render (C.Edges.find -> id is it.get \meta.create_user_id), D.user-edges
  V.user-nodes.render (C.Nodes.find -> id is it.get \meta.create_user_id), D.user-nodes

function signout then
  if m = C.Sessions.models.0 then m.destroy { error:H.on-err, success: -> navigate \session-info }
  else navigate \session-info
