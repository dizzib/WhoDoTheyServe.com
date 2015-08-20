# maintenance task to check all evidence urls and save a list of dead ones
# to the hive, to be highlighted in the app for manual resolution

Chalk = require \chalk
_     = require \lodash
M     = require \mongoose
Req   = require \request
Shell = require \shelljs/global
W4    = require \wait.for .for
Cfg   = require \../config

module.exports =
  # readline is DI'd because multiple instances causes odd behaviour
  dev    : (rl) -> W4 run, rl, Cfg.dev.primary.WDTS_DB_URI
  staging: (rl) -> W4 run, rl, Cfg.staging.primary.WDTS_DB_URI
  prod   : (rl) -> W4 run, rl, (JSON.parse env.prod).mongolab.uri

function run rl, db-uri, cb
  # require here to avoid bootstrap
  Hive  = require \../../site/api/hive
  M-Evs = require \../../site/api/model/evidences

  dead      = []   # dead evidences
  n-max     = 9999 # reduce limit to test
  n-pending = 0    # current number of http requests curling

  log "db-uri=#db-uri"
  M.connect db-uri
  err, evs <- M-Evs.find!lean!exec
  bail err if err
  err <- Hive.init
  bail err if err
  log hive-evs = Hive.get \evidences
  d-ids = JSON.parse(hive-evs).'dead-ids'
  ans <- rl.question "Check All (#{evs.length}) or just dead (#{d-ids.length}) (A/d)?"
  switch ans
  | \A => add-next evs
  | \d =>
    evs := _.filter evs, -> it._id in d-ids
    if evs.length then add-next evs else bail!
  | _ => bail!

  # helpers

  function add-dead ev, err
    print Chalk.red "#{ev.url} #err"
    dead.push ev
    save-if-done!

  function add-next evs
    return unless n-max--
    return unless ev = evs.pop!
    check ev
    _.delay (-> add-next evs), 100ms # avoid running too many requests in parallel

  function bail err
    M.disconnect!
    cb err

  function check ev
    print url = ev.url
    n-pending++
    try
      r = Req url, { strictSSL:false timeout:20000ms }, (err, res) ->
        return add-dead ev, err if err
        sc = res.statusCode
        # for some reason, cpexposed.com returns 402 (payment required) even though it's ok
        return add-dead ev, Chalk.magenta "response code = #sc" unless sc in [200 402]
        save-if-done!
      r.on \data ->
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
    dead-ids = _.pluck dead, \_id
    value = 'dead-ids':dead-ids
    log "found #{Chalk.cyan dead-ids.length} dead-ids: #dead-ids"
    ans <- rl.question "Update database #db-uri (y/N) ?"
    return bail! unless ans is \y
    err <- Hive.set \evidences JSON.stringify value
    log 'Database updated!' unless err
    bail err
