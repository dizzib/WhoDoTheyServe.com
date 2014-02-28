Assert = require \assert
Chalk  = require \chalk
Shell  = require \shelljs/global
W4     = require \wait.for .for
G      = require \./growl

const BAK-ROOT   = "$HOME/data/prod-db-dump"
const BAK-DIR    = "#BAK-ROOT/wdts"
const STAGING-DB = "wdts_staging"

try
  cfg = (JSON.parse env.prod).mongolab
  Assert dbid = cfg.dbid
  Assert host = cfg.host
  Assert uri  = cfg.uri
  Assert uid  = cfg.login.uid
  Assert pwd  = cfg.login.pwd
catch

module.exports =
  is-cfg: -> cfg?

  dump-prod-to-backup: ->
    try
      W4 exec, "mongodump --host #host --db #dbid -u #uid -p #pwd -o #BAK-ROOT"
      G.ok 'dumped PRODUCTION db to backup'
    catch e
      log e

  restore-backup-to-staging: ->
    try
      W4 exec, "mongorestore --db #STAGING-DB --drop #BAK-DIR"
      G.ok "restored backup db to #STAGING-DB"
    catch e
      log e

  restore-backup-to-prod: ->
    try
      #W4 exec, "mongorestore --host #host --db #dbid -u #uid -p #pwd --drop #BAK-DIR"
      G.ok "restored backup db to PRODUCTION"
    catch e
      log e

  show-config: -> log cfg
