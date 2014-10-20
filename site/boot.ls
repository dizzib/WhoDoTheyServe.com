global.log = console.log

Http      = require \http
Express   = require \./server
OpenAuth  = require \./api/authenticate/openauth
OpenAuthM = require \./api/authenticate/openauth-mock if process.env.NODE_ENV is \test
Db        = require \./api/db
Hive      = require \./api/hive
Router    = require \./api/router
HiveMap   = require \./boot/hive/map
MigrateDb = require \./boot/migrate-db

Db.connect!
err <- HiveMap.boot
console.error err if err
<- Hive.init
<- Http.createServer(Express).listen port = Express.settings.port
console.log "Express server http listening on port #{port}"
