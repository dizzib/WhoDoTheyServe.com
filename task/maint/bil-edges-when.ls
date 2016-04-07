# maintenance task to tidy Bilderberg 'attends' edges having unnecessary when

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
  M-Edges = require \../../site/api/model/edges

  log "db-uri=#db-uri"
  M.connect db-uri
  err, docs <- M-Edges.find
  return bail err if err
  const RX = /^\d{4}-\d{4}$/
  for doc in fix-docs = _.filter(docs, -> it.how is \attends and RX.test it.when)
    log doc
    doc.when = ''
  ans <- rl.question "Fix #{fix-docs.length} of #{docs.length} edges. Apply? (y/N)"
  return bail! unless ans is \y
  apply-next-fix!

  function bail err
    M.disconnect!
    cb err

  function apply-next-fix
    unless doc = fix-docs.shift!
      log \done!
      return bail!
    log "saving #{doc._id}"
    err <- doc.save!
    return bail err if err
    apply-next-fix!
