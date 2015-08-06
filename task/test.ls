_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
Cp     = require \child_process
Mg     = require \mongoose
W4     = require \wait.for .for
Shell  = require \shelljs/global
Dir    = require \./constants .dir
Cfg    = require \./config
G      = require \./growl
Rt     = require \./runtime
Site   = require \./site

const GLOB_1 = 'test/_unit/**/*.js test/_integration/api/**/*.js test/_integration/api.js'
const GLOB_2 = 'test/_integration/app.js'
const MOCHA  = "#{Dir.ROOT}/node_modules/.bin/_mocha --reporter spec --bail"

module.exports =
  cancel: kill-all-mocha
  exec: (cb) -> recycle-tests (c = Cfg.dev).test_1, c.tester_1, site-logging:true, c.dirsite, GLOB_1, "Unit & api tests", cb
  loop:
    dev_2: (flags) -> loop-dev_2 flags
  run:
    dev_1  : (flags) -> run_1 Cfg.dev, flags
    dev_2  : (flags) -> run_2 Cfg.dev, flags
    dev    : (flags) -> run Cfg.dev, flags
    staging: (flags) -> run Cfg.staging, flags, ' for staging'

## helpers

function drop-db cfg, cb
  <- (conn = Mg.createConnection cfg.WDTS_DB_URI).on \open
  e <- conn.db.dropDatabase
  throw new Error "drop-db failed: #e" if e
  conn.close!
  cb!

function get-mocha-cmd glob then "#MOCHA #glob"

function kill-all-mocha
  W4 kill-mocha, GLOB_1
  W4 kill-mocha, GLOB_2

function kill-mocha glob, cb
  Rt.kill-node (get-mocha-cmd glob), cb

function loop-dev_2 flags
  <- run_2 Cfg.dev, flags, ''
  loop-dev_2 flags

function run
  run_1 ...
  run_2 ...

function run_1 cfg, flags, desc = ''
  recycle-tests cfg.test_1, cfg.tester_1, flags, cfg.dirsite, GLOB_1, "Unit & api tests#desc"

function run_2 cfg, flags, desc = '', cb
  recycle-tests cfg.test_2, cfg.tester_2, flags, cfg.dirsite, GLOB_2, "App tests#desc", cb

function recycle-tests cfg-test, cfg-tester, flags, dirsite, glob, desc, cb
  cfg-test.COVERAGE = flags.test-coverage if cfg-test.COVERAGE_FLAG
  <- kill-mocha glob
  G.say "#desc started"
  start = Date.now!
  <- Site.stop cfg-test
  <- drop-db cfg-test
  <- Site.start dirsite, cfg-test, flags
  err <- start-mocha cfg-tester, flags, glob
  if err then G.err err else G.ok "#desc passed in #{(Date.now! - start)/1000}s"
  cb err if cb

function start-mocha cfg, flags, glob, cb
  if _.isFunction glob then [glob, cb] = [void, glob] # variadic
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
