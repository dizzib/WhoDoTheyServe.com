# maintenance task to list all invalid evidence urls and optionally fix for a domain

Chalk = require \chalk
_     = require \lodash
M     = require \mongoose
Shell = require \shelljs/global
W4    = require \wait.for .for
Cfg   = require \../config

const FIX-DOMAIN = \bilderbergmeetings.org

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
  for ev in bad-evs = _.reject(evs, -> Cons.url.regex.test it.url)
    log ev.entity_id, ev.url
  fix-evs = _.filter bad-evs, -> _.includes it.url, FIX-DOMAIN
  log "#{bad-evs.length} bad out of #{evs.length} evidences"
  ans <- rl.question "Fix #{fix-evs.length} #FIX-DOMAIN (y/N) ?"
  return bail! unless ans is \y
  fix-next!

  function bail err
    M.disconnect!
    cb err

  function fix-next
    const RX = /^(https?:\/\/web\.archive\.org\/web\/\d+\/)(.*)$/
    unless ev = fix-evs.shift!
      log \done!
      return bail!
    err, doc <- M-Evs.findById ev._id
    return bail err if err
    doc.url .= replace RX, '$2'
    log doc
    bail new Error "Invalid url #{doc.url}" unless Cons.url.regex.test doc.url
    err, doc <- doc.save!
    return bail err if err
    fix-next!
