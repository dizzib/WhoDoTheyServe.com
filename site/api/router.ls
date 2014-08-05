Analytics   = require \./analytics
H           = require \./helper
Hive        = require \./hive
Integrity   = require \./integrity
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

exports.init = (express) ->
  express
    ..param \id , (req,, next, req.id)  -> next!
    ..param \key, (req,, next, req.key) -> next!
    ..options \*, (, res) -> res.send 200

  express
    ..get  "/api/sys"              , Analytics.measure
    ..get  "/api/sys"              , Sys.get
    ..get  "/api/evidences/for/:id", M-Evidences.crud-fns.list-for-entity
    ..get  "/api/notes/for/:id"    , M-Notes.crud-fns.list-for-entity
   #..get "/api/users/:id/verify/:token", M-Users.verify

  set-api-sec-hive!
  set-api-sec-sessions!
  set-api-sec-users!
  set-api-sec \evidences , M-Evidences
  set-api-sec \edges     , M-Edges
  set-api-sec \maps      , M-Maps
  set-api-sec \nodes     , M-Nodes
  set-api-sec \notes     , M-Notes
  set-api-hive!
  set-api-integrity!
  set-api-crud \evidences, M-Evidences
  set-api-crud \edges    , M-Edges
  set-api-crud \maps     , M-Maps
  set-api-crud \nodes    , M-Nodes
  set-api-crud \notes    , M-Notes
  set-api-crud-logins! # must run before M-Users because M-Users.create needs login_id
  set-api-crud \users    , M-Users
  set-api-crud-sessions!

  function set-api-crud route, Model then
    express
      ..get    "/api/#{route}"    , Model.crud-fns.list
      ..post   "/api/#{route}"    , Model.crud-fns.create
      ..get    "/api/#{route}/:id", Model.crud-fns.read
      ..put    "/api/#{route}/:id", Model.crud-fns.update
      ..delete "/api/#{route}/:id", Model.crud-fns.delete

  function set-api-crud-logins then
    express
      ..post   "/api/users"       , M-Logins.crud-fns.create
      ..get    "/api/users/:id"   , M-Logins.crud-fns.read
      ..put    "/api/users/:id"   , M-Logins.crud-fns.update
      #..delete "/api/users/:id"   , M-Logins.crud-fns.delete

  function set-api-crud-sessions then
    express
      ..get    "/api/sessions"    , M-Sessions.crud-fns.list
      ..post   "/api/sessions"    , M-Sessions.crud-fns.create
      ..delete "/api/sessions/:id", M-Sessions.crud-fns.delete

  function set-api-hive then
    express
      ..get  "/api/hive/:key"    , Hive.read
      ..post "/api/hive/:key"    , Hive.write
      ..put  "/api/hive/:key/:id", Hive.write

  function set-api-sec route, Model then
    express
      ..post   "/api/#{route}"    , Sec.create Model
      ..put    "/api/#{route}/:id", Sec.amend Model
      ..delete "/api/#{route}/:id", Sec.amend Model

  function set-api-sec-hive then
    express
      ..post "/api/hive/:key", Sec.admin
      ..put  "/api/hive/:key", Sec.admin

  function set-api-sec-sessions then
    express
      ..post   "/api/sessions"    , SecSessions.create!
      ..delete "/api/sessions/:id", SecSessions.delete!

  function set-api-sec-users then
    express
      ..post   "/api/users"    , SecUsers.create!
      ..put    "/api/users/:id", SecUsers.maintain!
      ..delete "/api/users/:id", SecUsers.maintain!

  function set-api-integrity then
    express
      ..post   "/api/edges"    , Integrity.edge-create
      ..put    "/api/edges/:id", Integrity.edge-update
      ..delete "/api/edges/:id", Integrity.edge-delete
      ..post   "/api/nodes"    , Integrity.node-create
      ..put    "/api/nodes/:id", Integrity.node-update
      ..delete "/api/nodes/:id", Integrity.node-delete
