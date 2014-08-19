F         = require \fs
Http      = require \http
Https     = require \https
Server    = require \./server
OpenAuth  = require \./api/authenticate/openauth
OpenAuthM = require \./api/authenticate/openauth-mock
Db        = require \./api/db
Hive      = require \./api/hive
ApiRouter = require \./api/router
DeployMap = require \./deploy/hive/map
MigUsers  = require \./deploy/migrate-users

Db.connect!
Hive.init DeployMap.set-icons

# TODO: remove temporary migration code
err <- MigUsers.drop-indexes
err <- MigUsers.migrate
(console.log err) if err

OpenAuth.init! # must be called prior to setting up express routes (in Server.init)
OpenAuthM.init! if process.env.NODE_ENV is \test
ApiRouter.init express = Server.init!

<- Http.createServer(express).listen port = express.settings.port
console.log "Express server http listening on port #{port}"
