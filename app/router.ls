B  = require \backbone
_ = require \underscore
H  = require \./helper
C  = require \./collection
M  = require \./model
V  = require \./view
VC = require \./view-composer
VD = require \./view-directive
VH = require \./view-handler

Router = B.Router.extend do
  after: ->
    VH.ready!
  before: ->
    B.trigger \route-before
    VH.reset!
  routes:
    ''                 : \graph
    \doc/about         : \doc_about
    \edge/edit/:id     : \edge_edit
    \edge/new          : \edge_new
    \edge/new/:node_id : \edge_new
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
  edge        : VC.edge
  edges       : VC.edges
  edge_edit   : -> V.edge-edit.render (M.Edge.create it), C.Edges
  edge_new    : -> V.edge-edit.render (new M.Edge a_node_id:it, b_node_id:it), C.Edges
  graph       : -> V.graph.render!
  home        : -> V.home.render!
  node        : VC.node
  nodes       : VC.nodes
  node_edit   : -> V.node-edit.render (M.Node.create it), C.Nodes
  session     : -> V.session.render!
  user        : VC.user
  user_edit   : -> V.user-edit.render (M.User.create it), C.Users
  user_list   : -> V.users.render C.Users, VD.users
  user_signin : -> V.user-signin.render M.Session.create!, C.Sessions
  user_signup : -> V.user-signup.render M.Signup.create!, C.Users
  user_signout: -> V.user-signout.render!

module.exports = new Router!
