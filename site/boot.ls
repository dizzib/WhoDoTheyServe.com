F         = require \fs
Http      = require \http
Https     = require \https
Express   = require \./server
OpenAuth  = require \./api/authenticate/openauth
OpenAuthM = require \./api/authenticate/openauth-mock if process.env.NODE_ENV is \test
Db        = require \./api/db
Hive      = require \./api/hive
Router    = require \./api/router
DeployMap = require \./deploy/hive/map

Db.connect!
Hive.init DeployMap.set-icons

<- Http.createServer(Express).listen port = Express.settings.port
console.log "Express server http listening on port #{port}"
