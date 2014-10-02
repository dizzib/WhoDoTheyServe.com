# maintenance task to check all evidence urls and save a list of dead ones
# to the hive, to be highlighted in the app for manual resolution

Chalk = require \chalk
_     = require \lodash
M     = require \mongoose
Mc    = require \mongodb .MongoClient
Req   = require \request
Shell = require \shelljs/global
W     = require \wait.for
W4    = require \wait.for .for
W4m   = require \wait.for .forMethod
Cfg   = require \../config
Hive  = require \../../site/api/hive

module.exports =
  # readline is DI'd because multiple instances causes odd behaviour
  dev    : (rl) -> W4 run, rl, Cfg.dev.primary.WDTS_DB_URI
  staging: (rl) -> W4 run, rl, Cfg.staging.primary.WDTS_DB_URI
  prod   : (rl) -> W4 run, rl, (JSON.parse env.prod).mongolab.uri

function run rl, db-uri, cb
  dead      = []    # dead evidences
  n-max     = 99999 # reduce limit to test
  n-pending = 0     # current number of http requests curling

  log "db-uri=#db-uri"
  err, db <- Mc.connect db-uri
  return cb err if err
  coll = db.collection \evidences
  err, cursor <- coll.find
  add-next!

  function add-next
    return unless n-max-- > 0
    err, ev <- cursor.nextObject
    return cb err if err
    return unless ev
    check ev
    _.delay add-next, 50ms # avoid running too many requests in parallel

  # helpers

  function add-dead ev, err
    print Chalk.red "#{ev.url} #err"
    dead.push ev
    save-if-done!

  function check ev
    print url = ev.url
    n-pending++
    try
      r = Req url, timeout:15000ms, (err, res) ->
        return add-dead ev, err if err
        sc = res.statusCode
        # for some reason, cpexposed.com returns 402 (payment required) even though it's ok
        return add-dead ev, Chalk.magenta "response code = #sc" unless sc in [ 200, 402 ]
        save-if-done!
      r.on \data, ->
        r.abort!
        print Chalk.green "#url is ok"
        save-if-done!
    catch e
      add-dead ev, e

  function pause ms, cb
    _.delay cb, ms

  function print msg
    log "#n-pending #msg"

  function save-if-done
    return unless --n-pending is 0
    db.close!
    dead-ids = _.pluck dead, \_id
    value = 'dead-ids':dead-ids
    log "found #{Chalk.yellow dead-ids.length} dead-ids: #dead-ids"
    ans <- rl.question "Update database #db-uri (y/N) ?"
    return cb! unless ans is \y
    M.connect db-uri
    err <- Hive.set \evidences, JSON.stringify value
    return cb err if err
    M.disconnect!
    log 'Database updated!'
    cb!
