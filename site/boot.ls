global.log = console.log

F         = require \fs
Http      = require \http
Https     = require \https
WFib      = require \wait.for .launchFiber
Express   = require \./server
OpenAuth  = require \./api/authenticate/openauth
OpenAuthM = require \./api/authenticate/openauth-mock if process.env.NODE_ENV is \test
Db        = require \./api/db
Hive      = require \./api/hive
Router    = require \./api/router
DeployMap = require \./deploy/hive/map
MigEdges  = require \./deploy/migrate-edges-when

Db.connect!
Hive.init DeployMap.set-icons

WFib MigEdges.migrate # TODO: remove

<- Http.createServer(Express).listen port = Express.settings.port
console.log "Express server http listening on port #{port}"
