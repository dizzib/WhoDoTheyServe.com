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
err <- Hive.init
console.error err if err
err <- HiveMap.boot
console.error err if err

const msg = 'Express server http listening on'
port = process.env.PORT or process.env.OPENSHIFT_NODEJS_PORT or 80
if host = process.env.OPENSHIFT_NODEJS_IP
  return Server.listen port, host, -> log "#msg #host:#port"
Server.listen port, -> log "#msg port #port"
