F         = require \fs
Http      = require \http
Https     = require \https
Server    = require \./server
DB        = require \./api/db
Hive      = require \./api/hive
Oauth     = require \./api/oauth
ApiRouter = require \./api/router
DH-Graph  = require \./deploy/hive/map

DB.connect!
Hive.init DH-Graph.set-icons

Oauth.init! # must be called prior to setting up express routes (in Server.init)
ApiRouter.init express = Server.init!

<- Http.createServer(express).listen port = express.settings.port
console.log "Express server http listening on port #{port}"
