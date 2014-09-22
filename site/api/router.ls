Passport    = require \passport
Analytics   = require \./analytics
A-OpenAuth  = require \./authenticate/openauth
A-Password  = require \./authenticate/password
Express     = require \../server
H           = require \./helper
Hive        = require \./hive
I-Edge      = require \./integrity/edge
I-Entity    = require \./integrity/entity
I-Node      = require \./integrity/node
M-Edges     = require \./model/edges
M-Maps      = require \./model/maps
M-Nodes     = require \./model/nodes
M-Notes     = require \./model/notes
M-Evidences = require \./model/evidences
M-Logins    = require \./model/logins
M-Sessions  = require \./model/sessions
M-Users     = require \./model/users
Sec         = require \./security
SecSessions = require \./security/sessions
SecUsers    = require \./security/users
Sys         = require \./sys

module.exports = me =
  # used by openauth-mock
  set-api-openauth: (auth-type, path = auth-type, l1-opts = {}, l2-opts = {}) ->
    const L2-OPTS = failureRedirect:'/#/user/signin/error'
    Express
      ..get "/api/auth/#path"         , SecSessions.before-authenticate
      ..get "/api/auth/#path"         , Passport.authenticate auth-type, l1-opts
      ..get "/api/auth/#path/callback", Passport.authenticate auth-type, L2-OPTS <<< l2-opts
      ..get "/api/auth/#path/callback", SecSessions.after-authenticate
      ..get "/api/auth/#path/callback", A-OpenAuth.callback

Express
  ..all '/api/*', (req, res, next) ->
    # Production api requests normally bypass CF entirely via the api domain (see /app/api.ls).
    # However, some api requests (such as the openauth initial request) come via
    # www.whodotheyserve.com/api, and here we prevent CF from caching such requests.
    res.header \Cache-Control, \no-cache
    next!
  ..param \id , (req,, next, req.id)  -> next!
  ..param \key, (req,, next, req.key) -> next!
  ..options \*, (, res) -> res.send 200

# security
set-api-sec-hive!
set-api-sec-sessions!
set-api-sec-sys!
set-api-sec-users!
set-api-sec \evidences , M-Evidences
set-api-sec \edges     , M-Edges
set-api-sec \maps      , M-Maps
set-api-sec \nodes     , M-Nodes
set-api-sec \notes     , M-Notes

# general
Express
  ..delete "/api/users/:id", (req, res ,next) ->
    M-Sessions.signout req, id:req.id if req.id is req.session.signin.id # signout before self delete
    next!
  ..get "/api/evidences/for/:id", M-Evidences.crud-fns.list-for-entity
  ..get "/api/notes/for/:id"    , M-Notes.crud-fns.list-for-entity
set-api-hive!
set-api-integrity!
set-api-sys!

# crud
set-api-crud-logins! # must run before M-Users because M-Users needs req.login
set-api-crud-sessions!
set-api-crud \evidences, M-Evidences
set-api-crud \edges    , M-Edges
set-api-crud \maps     , M-Maps
set-api-crud \nodes    , M-Nodes
set-api-crud \notes    , M-Notes
set-api-crud \users    , M-Users

# openauth
me.set-api-openauth \facebook
me.set-api-openauth \github
me.set-api-openauth \google

## helpers

function set-api-crud route, Model
  Express
    ..get    "/api/#{route}"    , Model.crud-fns.list
    ..post   "/api/#{route}"    , Model.crud-fns.create
    ..get    "/api/#{route}/:id", Model.crud-fns.read
    ..put    "/api/#{route}/:id", Model.crud-fns.update
    ..delete "/api/#{route}/:id", Model.crud-fns.delete

function set-api-crud-logins
  Express
    ..post   "/api/users"       , M-Logins.crud-fns.create
    ..get    "/api/users/:id"   , M-Logins.crud-fns.read
    ..put    "/api/users/:id"   , M-Logins.crud-fns.update
    ..delete "/api/users/:id"   , M-Logins.crud-fns.delete

function set-api-crud-sessions
  Express
    ..post   "/api/sessions"    , M-Sessions.crud-fns.create
    ..get    "/api/sessions"    , M-Sessions.crud-fns.read
    ..delete "/api/sessions/:id", M-Sessions.crud-fns.delete

function set-api-hive
  Express
    ..get  "/api/hive/:key"    , Hive.read
    ..post "/api/hive/:key"    , Hive.write
    ..put  "/api/hive/:key/:id", Hive.write

function set-api-integrity
  Express
    ..post   "/api/edges"    , I-Edge.create
    ..post   "/api/edges"    , I-Entity.create M-Edges
    ..put    "/api/edges/:id", I-Edge.update
    ..delete "/api/edges/:id", I-Edge.delete
    ..post   "/api/nodes"    , I-Entity.create M-Nodes
    ..put    "/api/nodes/:id", I-Node.update
    ..delete "/api/nodes/:id", I-Node.delete

function set-api-sec route, Model
  Express
    ..post   "/api/#{route}"    , Sec.create Model
    ..put    "/api/#{route}/:id", Sec.amend Model
    ..delete "/api/#{route}/:id", Sec.amend Model

function set-api-sec-hive
  Express
    ..post "/api/hive/:key", Sec.admin
    ..put  "/api/hive/:key", Sec.admin

function set-api-sec-sessions
  Express
    ..post   "/api/sessions"    , SecSessions.before-authenticate
    ..post   "/api/sessions"    , A-Password.authenticate
    ..post   "/api/sessions"    , SecSessions.after-authenticate
    ..delete "/api/sessions/:id", SecSessions.delete

function set-api-sec-sys
  Express
    ..get  "/api/sys/mode/toggle", Sec.admin

function set-api-sec-users
  Express
    ..post   "/api/users"    , SecUsers.create
    ..get    "/api/users/:id", SecUsers.maintain # read is only permitted for maintenance
    ..put    "/api/users/:id", SecUsers.maintain
    ..delete "/api/users/:id", SecUsers.maintain

function set-api-sys
  Express
    ..get  "/api/sys"            , Analytics.measure
    ..get  "/api/sys"            , Sys.read
    ..get  "/api/sys/mode/toggle", Sys.toggle-mode
