F         = require \fs
Http      = require \http
Https     = require \https
Server    = require \./server
DB        = require \./api/db
Hive      = require \./api/hive
ApiRouter = require \./api/router
S-Graph   = require \./script/data/graph

require \./bundler .init! if Server.settings.env is \development

DB.connect!
Hive.init S-Graph.set-images
ApiRouter.init Server

<- Http.createServer(Server).listen port = Server.settings.port
console.log "Express server http listening on port #{port}"
