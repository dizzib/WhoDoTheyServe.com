F         = require \fs
Http      = require \http
Https     = require \https
Server    = require \./server
DB        = require \./api/db
Hive      = require \./api/hive
ApiRouter = require \./api/router
DH-Graph  = require \./deploy/hive/map

DB.connect!
Hive.init DH-Graph.set-icons
ApiRouter.init Server

<- Http.createServer(Server).listen port = Server.settings.port
console.log "Express server http listening on port #{port}"
