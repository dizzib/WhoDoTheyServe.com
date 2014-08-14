B  = require \backbone
Qs = require \querystring
_  = require \underscore
H  = require \./helper
Hi = require \./history
Hv = require \./hive
C  = require \./collection
F  = require \./fireprox
M  = require \./model
Mx = require \./model-ext
V  = require \./view
Vc = require \./view-composer

Router = B.Router.extend do
  after: ->
    V.finalise!
  before: ->
    B.trigger \route-before
    V.reset!
  routes:
    \__coverage          : coverage
    ''                   : \map_default
    \admin               : \admin
    \doc/about           : \doc_about
    \edge/edit/:id       : \edge_edit
    \edge/new            : \edge_edit
    \edge/:id            : \edge
    \edge/:id/:act       : \edge
    \edge/:id/:act/:id   : \edge
    \edges               : \edges
    \fireprox            : \fireprox
    \latest              : \latest
    \map/new             : \map
    \map/:id             : \map
    \node/edit/:id       : \node_edit
    \node/new            : \node_edit
    \node/:id            : \node
    \node/:id/:act       : \node
    \node/:id/:act/:id   : \node
    \nodes               : \nodes
    \user                : \user
    \user/edit/:id       : \user_edit
    \user/signin         : \user_signin
    \user/signin/error   : \user_signin_err
    \user/signin/error:q : \user_signin_err
    \user/signout        : \user_signout
    \user/signup         : \user_signup
    \user/:id            : \user
    \users               : \users
    \*nomatch            : \map_default
  admin          : -> V.admin.render M.Sys
  doc_about      : -> V.doc-about.render!
  edge           : -> Hi.set-edge Vc.edge ...
  edge_edit      : -> V.edge-edit.render (M.Edge.create it), C.Edges
  edges          : Vc.edges
  fireprox       : F.setup-url
  latest         : -> V.latest.render!
  map            : Vc.map
  map_default    : -> Vc.map (JSON.parse Hv.Map.get \value).default?id
  node           : -> Hi.set-node-id Vc.node ...
  node_edit      : -> V.node-edit.render (M.Node.create it), C.Nodes
  nodes          : Vc.nodes
  user           : Vc.user
  user_edit      : -> V.user-edit.render (M.User.create it), C.Users
  user_signin    : -> V.user-signin.render M.Session.create!, C.Sessions
  user_signin_err: -> V.user-signin-err.render it
  user_signout   : -> V.user-signout.render!
  user_signup    : -> V.user-signup.render M.Signup.create!, C.Users
  users          : Vc.users

module.exports = new Router!

## helpers

function coverage # https://github.com/gotwarlost/istanbul-middleware
  H.post-json '/coverage/client', window.__coverage__
