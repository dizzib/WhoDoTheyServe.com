# maintenance task to list all invalid evidence urls

Chalk = require \chalk
_     = require \lodash
M     = require \mongoose
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
  Cons  = require \../../site/lib/model/constraints
  M-Evs = require \../../site/api/model/evidences

  log "db-uri=#db-uri"
  M.connect db-uri
  err, evs <- M-Evs.find!lean!exec
  return bail err if err

  for ev in _.reject(evs, -> Cons.url.regex.test it.url)
    log ev.entity_id, ev.url
  log "finished checking #{evs.length} evidences"
  bail!

  function bail err
    M.disconnect!
    cb err
