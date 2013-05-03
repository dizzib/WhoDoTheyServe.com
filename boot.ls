F         = require \fs
Http      = require \http
Https     = require \https
Server    = require \./server
DB        = require \./api/db
ApiRouter = require \./api/router
SeoEngine = require \./seo/engine

require \./bundler .init! if Server.settings.env is \development

DB.connect!
ApiRouter.init Server
SeoEngine.init Server

<- Http.createServer(Server).listen port = Server.settings.port
console.log "Express server http listening on port #{port}"
