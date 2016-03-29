# maintenance task to list all invalid evidence urls and optionally fix them

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
  err, evs <- M-Evs.find
  return bail err if err
  const RX = /^(https?:\/\/web\.archive\.org\/web\/(\d{8})\d+\/)(.*)$/
  for ev in fix-evs = _.filter(evs, -> RX.test it.url)
    res = RX.exec ev.url
    ev.timestamp = res.2
    ev.url = res.3
    log ev
  ans <- rl.question "Fix #{fix-evs.length} of #{evs.length} evidences. Apply? (y/N)"
  return bail! unless ans is \y
  apply-next-fix!

  function bail err
    M.disconnect!
    cb err

  function apply-next-fix
    unless ev = fix-evs.shift!
      log \done!
      return bail!
    bail new Error "Invalid url #{ev.url}" unless Cons.url.regex.test ev.url
    log "saving #{ev._id}"
    err, ev <- ev.save!
    return bail err if err
    apply-next-fix!
