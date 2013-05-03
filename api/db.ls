M       = require \mongoose
H       = require \./helper
Server  = require \../server
Cache-C = require \./db-cache/collection-cache
Cache-Q = require \./db-cache/query-by-entity-cache
Store   = require \./db-cache/in-process-store
Sweeper = require \./db-cache/sweeper

exports.connect = ->
  throw new Error 'WDTS_DB_URI not set' unless db-uri = process.env.WDTS_DB_URI
  H.log "ENV=#{env = Server.settings.env}"
  H.log "db-uri=#{db-uri}" if env in <[ development test staging ]>
  M.connect db-uri

  if process.env.WDTS_DB_CACHE_ENABLE is \false
    H.log 'db-cache is disabled'
  else
    Sweeper.create store-c = Store.create!
    Sweeper.create store-q = Store.create!
    Cache-C.create store-c
    Cache-Q.create store-q
