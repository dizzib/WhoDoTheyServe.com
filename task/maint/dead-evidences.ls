# maintenance task to check all evidence urls and save a list of dead ones
# to the hive, to be highlighted in the app for manual resolution

_     = require \lodash
Chalk = require \chalk
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
  dev    : -> run Cfg.dev.primary.WDTS_DB_URI
  staging: -> run Cfg.staging.primary.WDTS_DB_URI
  prod   : -> run (JSON.parse env.prod).mongolab.uri

function run db-uri
  dead      = []    # dead evidences
  n-max     = 99999 # reduce limit to test
  n-pending = 0     # current number of http requests curling

  log "db-uri=#{db-uri}"
  <- W.launchFiber
  db = W4m Mc, \connect, db-uri
  coll = db.collection \evidences
  curs = W4m coll, \find
  while n-max-- > 0 and ev = W4m curs, \nextObject
    W4 pause, 50ms # avoid running too many requests in parallel
    check ev
  db.close!

  # helpers

  function add-dead ev, err
    print Chalk.red "#{ev.url} #{err}"
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
    if --n-pending is 0
      dead-ids = _.pluck dead, \_id
      value = 'dead-ids':dead-ids
      log "found #{Chalk.yellow dead-ids.length} dead-ids: #dead-ids"
      M.connect db-uri
      err <- Hive.set \evidences, JSON.stringify value
      log err if err
      M.disconnect!
      log 'DONE!'
