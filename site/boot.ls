global.log = console.log

Http      = require \http
Express   = require \./server
Db        = require \./api/db
Hive      = require \./api/hive
Router    = require \./api/router
HiveMap   = require \./boot/hive/map
MigrateDb = require \./boot/migrate-db

Db.connect!
<- Hive.init
err <- HiveMap.boot
console.error err if err
<- Http.createServer(Express).listen port = Express.settings.port
console.log "Express server http listening on port #{port}"
