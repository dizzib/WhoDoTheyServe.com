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

host = process.env.OPENSHIFT_NODEJS_IP
port = process.env.OPENSHIFT_NODEJS_PORT or process.env.PORT or 80
Server.listen port, host, ->
  const MSG = 'Express server http listening on'
  log if host then "#MSG #host:#port" else "#MSG port #port"
