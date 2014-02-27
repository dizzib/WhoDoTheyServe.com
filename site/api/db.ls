M       = require \mongoose
Cache-C = require \./db-cache/collection-cache
Cache-Q = require \./db-cache/query-by-entity-cache
Store   = require \./db-cache/in-process-store
Sweeper = require \./db-cache/sweeper

exports.connect = ->
  throw new Error 'WDTS_DB_URI not set' unless db-uri = process.env.WDTS_DB_URI
  log "ENV=#{env = process.env.NODE_ENV}"
  log "db-uri=#{db-uri}" if env in <[ development test staging ]>
  M.connect db-uri

  if process.env.WDTS_DB_CACHE_ENABLE is \false
    log 'db-cache is disabled'
  else
    Sweeper.create store-c = Store.create!
    Sweeper.create store-q = Store.create!
    Cache-C.create store-c
    Cache-Q.create store-q
