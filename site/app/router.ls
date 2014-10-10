B  = require \backbone
H  = require \./helper
C  = require \./collection
F  = require \./fireprox
Hm = require \./model/hive .instance.Map
V  = require \./view
Vc = require \./view-handler/composer
Vd = require \./view-handler/directive
Ui = require \./view-handler/ui

M-Edge = require \./model/edge
M-Node = require \./model/node
M-User = require \./model/user
M-Sess = require \./model/session

_navigate = B.Router.prototype.navigate
B.Router.prototype.navigate = -> _navigate it, trigger:true

r = B.Router.extend do
  execute: (cb, args, name) ->
    B.trigger \route-before
    Ui.reset!
    cb?apply this, args
    Ui.finalise!
  routes:
    \__coverage        : -> H.post-json '/coverage/client', window.__coverage__ # https://github.com/gotwarlost/istanbul-middleware
    ''                 : \map_default
    \doc/about         : \doc_about
    \edge/edit/:id     : \edge_edit
    \edge/new          : \edge_edit
    \edge/:id          : \edge
    \edge/:id/:act     : \edge
    \edge/:id/:act/:id : \edge
    \edges             : \edges
    \fireprox          : \fireprox
    \latest            : \latest
    \map/new           : \map
    \map/:id           : \map
    \node/edit/:id     : \node_edit
    \node/new          : \node_edit
    \node/:id          : \node
    \node/:id/:act     : \node
    \node/:id/:act/:id : \node
    \nodes             : \nodes
    \sys               : \sys
    \user              : \user
    \user/edit/:id     : \user_edit
    \user/signin       : \user_signin
    \user/signin/error : \user_signin_err
    \user/signout      : \user_signout
    \user/signup       : \user_signup
    \user/:id          : \user
    \users             : \users
    \*nomatch          : \map_default
  doc_about      : -> V.doc-about.render!
  edge           : -> Vc.edge ...
  edge_edit      : -> V.edge-edit.render (M-Edge.create it), C.Edges
  edges          : Vc.edges
  fireprox       : F.configure
  latest         : -> V.latest.render!
  map            : Vc.map
  map_default    : -> if id = Hm.default-id then Vc.map id else H.show-error 'Please set default map'
  node           : -> Vc.node ...
  node_edit      : -> V.node-edit.render (M-Node.create it), C.Nodes
  nodes          : Vc.nodes
  sys            : -> V.sys.render!
  user           : Vc.user
  user_edit      : -> V.user-edit.render (M-User.create it), C.Users
  user_signin    : -> V.user-signin.render M-Sess.create!, C.Sessions
  user_signin_err: -> V.user-signin-err.render it
  user_signout   : -> V.user-signout.render!
  user_signup    : -> V.user-signup.render M-User.create!, C.Users
  users          : -> V.users.render C.Users, Vd.users

module.exports = new r!
