Query = require \mongoose .Query
_     = require \lodash

exports.create = (store) -> new Sweeper store

class Sweeper
  (@@store) ->
    sweep-period-mins = process.env.WDTS_DB_CACHE_SWEEP_PERIOD_MINS or 60mins
    throw new Error "sweep-period-mins must be > 0" unless sweep-period-mins > 0
    throw new Error "sweep-period-mins must be <= 24 * 60" unless sweep-period-mins <= 24hours * 60mins
    sweep-period-ms = sweep-period-mins * 60secs * 1000ms
    log "db-cache will sweep every #{sweep-period-mins} minutes"
    queries = {}
    @@store.set-query = (coll-name, store-key, query) ->
      query.store-key = store-key
      queries[coll-name] = query
    _.delay sweep, sweep-period-ms

    function sweep
      #log 'sweep cache'
      @@store.clear!
      for k, q of queries
        sweep-coll k, q
      _.delay sweep, sweep-period-ms

    function sweep-coll coll-name, query
      err, docs <- Query::_execFind.call query
      if err then return console.error "sweep #{coll-name} failed: #{err}"
      @@store.set coll-name, query.store-key, docs
      #log "sweep #{coll-name} ok"
