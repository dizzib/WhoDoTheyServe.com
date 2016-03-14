Express     = require \express
Passport    = require \passport
Analytics   = require \./analytics
AuthPasswd  = require \./authenticate/password
H           = require \./helper
Hive        = require \./hive
I-Edge      = require \./integrity/edge
I-Entity    = require \./integrity/entity
I-Node      = require \./integrity/node
Latest      = require \./latest
M-Edges     = require \./model/edges
M-Maps      = require \./model/maps
M-Nodes     = require \./model/nodes
M-Notes     = require \./model/notes
M-Evidences = require \./model/evidences
M-Logins    = require \./model/logins
M-Sessions  = require \./model/sessions
M-Users     = require \./model/users
Sec         = require \./security
SecMaps     = require \./security/maps
SecSessions = require \./security/sessions
SecUsers    = require \./security/users
Sys         = require \./sys

module.exports = Express.Router!
  ..all '/*' (req, res, next) ->
    # Production api requests normally bypass CF entirely via the api domain (see /app/api.ls).
    # However, some api requests (such as the openauth initial request) come via
    # www.whodotheyserve.com/api, and here we prevent CF from caching such requests.
    res.header \Cache-Control \no-cache
    next!
  ..options '/*' (, res) -> res.send 200
  ..param \id extract-id
  # security
  ..use sec-hive!
  ..use sec-maps!
  ..use sec-sessions!
  ..use sec-sys!
  ..use sec-users!
  ..use sec \evidences M-Evidences
  ..use sec \edges     M-Edges
  ..use sec \maps      M-Maps
  ..use sec \nodes     M-Nodes
  ..use sec \notes     M-Notes
  # general
  ..delete '/users/:id' (req, res ,next) ->
    M-Sessions.signout req, id:req.id if req.id is req.session.signin.id # signout before self delete
    next!
  ..get '/evidences/for/:id' M-Evidences.crud-fns.list-for-entity
  ..get '/notes/for/:id'     M-Notes.crud-fns.list-for-entity
  ..use hive!
  ..use integrity!
  ..use latest!
  ..use sys!
  # crud
  ..use crud-logins! # must run before M-Users because M-Users needs req.login
  ..use crud-sessions!
  ..use crud \evidences M-Evidences
  ..use crud \edges     M-Edges
  ..use crud \maps      M-Maps
  ..use crud \nodes     M-Nodes
  ..use crud \notes     M-Notes
  ..use crud \users     M-Users

function extract-id  req,, next, req.id  then next!
function extract-key req,, next, req.key then next!

function crud route, Model then Express.Router!
  ..param \id extract-id
  ..get    "/#route"     Model.crud-fns.list
  ..post   "/#route"     Model.crud-fns.create
  ..get    "/#route/:id" Model.crud-fns.read
  ..put    "/#route/:id" Model.crud-fns.update
  ..delete "/#route/:id" Model.crud-fns.delete

function crud-logins then Express.Router!
  ..param \id extract-id
  ..post   '/users'     M-Logins.crud-fns.create
  ..get    '/users/:id' M-Logins.crud-fns.read
  ..put    '/users/:id' M-Logins.crud-fns.update
  ..delete '/users/:id' M-Logins.crud-fns.delete

function crud-sessions then Express.Router!
  ..param \id extract-id
  ..post   '/sessions'     M-Sessions.crud-fns.create
  ..get    '/sessions'     M-Sessions.crud-fns.read
  ..delete '/sessions/:id' M-Sessions.crud-fns.delete

function hive then Express.Router!
  ..param \id extract-id
  ..param \key extract-key
  ..get  '/hive/:key'     Hive.read
  ..post '/hive/:key'     Hive.write
  ..put  '/hive/:key/:id' Hive.write

function integrity then Express.Router!
  ..param \id extract-id
  ..post   '/edges'     I-Edge.create.node
  ..post   '/edges'     I-Edge.create.when
  ..post   '/edges'     I-Entity.create M-Edges
  ..put    '/edges/:id' I-Edge.update.node
  ..put    '/edges/:id' I-Edge.update.when
  ..delete '/edges/:id' I-Edge.delete
  ..post   '/nodes'     I-Entity.create M-Nodes
  ..put    '/nodes/:id' I-Node.update
  ..delete '/nodes/:id' I-Node.delete

function latest then Express.Router!
  ..get '/latest' Latest.list
  ..all '/edges'  Latest.bust-cache
  ..all '/maps'   Latest.bust-cache
  ..all '/nodes'  Latest.bust-cache
  ..all '/notes'  Latest.bust-cache

function sec route, Model then Express.Router!
  ..param \id extract-id
  ..post   "/#route"     Sec.create Model
  ..put    "/#route/:id" Sec.amend Model
  ..delete "/#route/:id" Sec.amend Model

function sec-hive then Express.Router!
  ..param \key extract-key
  ..post '/hive/:key' Sec.admin
  ..put  '/hive/:key' Sec.admin

function sec-maps then Express.Router!
  ..param \id extract-id
  ..get '/maps/:id' SecMaps.read

function sec-sessions then Express.Router!
  ..param \id extract-id
  ..post   '/sessions'     SecSessions.before-authenticate
  ..post   '/sessions'     AuthPasswd.authenticate
  ..post   '/sessions'     SecSessions.after-authenticate
  ..delete '/sessions/:id' SecSessions.delete

function sec-sys then Express.Router!
  ..get '/sys/mode/toggle' Sec.admin

function sec-users then Express.Router!
  ..param \id extract-id
  ..post   '/users'     SecUsers.create
  ..get    '/users/:id' SecUsers.maintain # read is only permitted for maintenance
  ..put    '/users/:id' SecUsers.maintain
  ..delete '/users/:id' SecUsers.maintain

function sys then Express.Router!
  ..get '/sys'             Analytics.measure
  ..get '/sys'             Sys.read
  ..get '/sys/mode/toggle' Sys.toggle-mode
