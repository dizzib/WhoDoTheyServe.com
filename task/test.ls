_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
Cp     = require \child_process
Mg     = require \mongoose
W4     = require \wait.for .for
Shell  = require \shelljs/global
Dir    = require \./constants .dir
Cfg    = require \./config
Flags  = require \./flags
G      = require \./growl
Rt     = require \./runtime
Site   = require \./site

const MOCHA = "#{Dir.ROOT}/node_modules/.bin/_mocha --reporter spec --bail"
const SCOPES =
  api:
    desc: 'Unit & api'
    glob: 'test/_unit/**/*.js test/_integration/api/**/*.js test/_integration/api.js'
  app:
    desc: 'App'
    glob: 'test/_integration/app.js'

module.exports = me =
  cancel: ->
    for k, v of SCOPES then W4 kill-mocha, v.glob
  loop: (env-id, scope-id) ->
    err <- run env-id, scope-id
    me.loop env-id, scope-id unless err
  run: (env-id, scope-id, cb) ->
    sids = if scope-id then [scope-id] else <[ api app ]>
    for sid in sids
      skip = env-id is \dev and not Flags.get!test.run[sid]
      if skip then log Chalk.cyan "skip #sid tests" else run env-id, sid, cb
  run-forced: run

## helpers

function drop-db cfg, cb
  <- (conn = Mg.createConnection cfg.WDTS_DB_URI).on \open
  e <- conn.db.dropDatabase
  throw new Error "drop-db failed: #e" if e
  conn.close!
  cb!

function get-mocha-cmd glob then "#MOCHA #glob"
function kill-mocha glob, cb then Rt.kill-node (get-mocha-cmd glob), cb

function run env-id, scope-id, cb
  scope = SCOPES[scope-id]
  desc = "#{scope.desc} tests (#env-id)"
  G.say "#desc started"
  start = Date.now!
  cfg = (env = Cfg[env-id]).test[scope-id]
  <- kill-mocha scope.glob
  <- Site.stop cfg.testee
  <- drop-db cfg.testee
  cfg.testee.COVERAGE = Flags.get!test.coverage if cfg.testee.COVERAGE_FLAG
  <- Site.start env.dirsite, cfg.testee
  err <- start-mocha cfg.tester, scope.glob
  if err then G.err err else G.ok "#desc passed in #{(Date.now! - start)/1000}s"
  cb err if cb

function start-mocha cfg, glob, cb
  v = exec 'node --version' silent:true .output.replace '\n' ''
  log "start mocha in node #v: #glob"
  cfg <<< firefox-host:env.firefox-host or \localhost
  cmd = get-mocha-cmd glob
  Cp.spawn \node (cmd.split ' '), cwd:Dir.BUILD, env:(env with cfg), stdio:[ 0, 1, void ]
    ..on \exit ->
      cb if it then (new Error "Exited with code #it") <<< code:it
    ..stderr.on \data ->
      log s = it.toString!
      # data may be fragmented, so only growl relevant packet
      const RX-ERR = /(expected|error|exception)/i
      G.alert (Chalk.stripColor s), nolog:true if RX-ERR.test s
