global.log = console.log

if process.env.COVERAGE is \true
  Im = require \istanbul-middleware
  Im.hookLoader __dirname # must come before other requires

Http      = require \http
Db        = require \./api/db
Hive      = require \./api/hive
Router    = require \./api/router
HiveMap   = require \./boot/hive/map
MigrateDb = require \./boot/migrate-db
Server    = require \./server

Db.connect!
<- Hive.init
err <- HiveMap.boot
console.error err if err
<- Http.createServer(Server).listen port = Server.settings.port
console.log "Express server http listening on port #{port}"
