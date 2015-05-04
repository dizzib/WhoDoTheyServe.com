global.log = console.log

if process.env.COVERAGE is \true
  require \istanbul-middleware .hookLoader __dirname # must come before other requires

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
<- Server.listen port = process.env.PORT || 80
console.log "Express server http listening on port #port"
