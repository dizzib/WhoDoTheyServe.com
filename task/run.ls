_       = require \lodash
Assert  = require \assert
Chalk   = require \chalk
Cp      = require \child_process
Mg      = require \mongoose
Shell   = require \shelljs/global
Cfg     = require \./config
Dir     = require \./constants .dir
DirSite = require \./constants .dir.site
G       = require \./growl

const MOCHA = "#{Dir.DEV}/node_modules/mocha/bin/mocha"
const MARGS = "--reporter spec --bail --recursive"

Cfg.dev     <<< dirsite:DirSite.DEV
Cfg.staging <<< dirsite:DirSite.STAGING

module.exports =
  cancel           : -> kill-mocha it
  loop-dev-test_2  : -> loop-dev-test_2!
  recycle-dev      : -> recycle-primary Cfg.dev
  recycle-staging  : -> recycle-primary Cfg.staging
  run-dev-test_1   : -> run-test_1 Cfg.dev
  run-dev-test_2   : -> run-test_2 Cfg.dev
  run-dev-tests    : -> run-tests Cfg.dev
  run-staging-tests: -> run-tests Cfg.staging, ' for staging'

## helpers

function drop-db cfg, cb
  Mg.connect cfg.WDTS_DB_URI
  e <- Mg.connection.db.executeDbCommand dropDatabase:1
  throw new Error "drop-db failed: #e" if e
  Mg.disconnect!
  cb!

function kill-mocha cb
  # mocha spawns a child process which we must also kill
  <- kill-node MOCHA.replace '/bin/mocha', '/bin/_mocha'
  <- kill-node MOCHA
  cb!

function kill-node args, cb
  # can't use WaitFor as we need the return code
  code, out <- exec cmd = "pkill -ef 'node #args'"
  # 0 One or more processes matched the criteria. 
  # 1 No processes matched. 
  # 2 Syntax error in the command line. 
  # 3 Fatal error: out of memory etc. 
  throw new Error "#cmd returned #code" if code > 1
  cb!

function loop-dev-test_2
  <- run-test_2 Cfg.dev, ''
  loop-dev-test_2!

function recycle-primary cfg, cb
  <- stop-site cfg.primary
  <- start-site cfg.dirsite, cfg.primary
  cb! if cb?

function run-tests
  run-test_1 ...
  run-test_2 ...

function run-test_1 cfg, desc = ''
  <- kill-mocha # this should always run before test-2, so safe to kill mocha
  <- recycle-primary cfg
  recycle-tests cfg.test_1, cfg.tester_1, cfg.dirsite, 'app --invert', "Unit & api tests#desc"

function run-test_2 cfg, desc = '', cb
  recycle-tests cfg.test_2, cfg.tester_2, cfg.dirsite, 'app', "App tests#desc", cb

function recycle-tests test, tester, dirsite, grep, desc, cb
  G.say "#desc started"
  start = Date.now!
  <- stop-site test
  <- drop-db test
  <- start-site dirsite, test
  e <- start-mocha tester, grep
  return G.err e if e?
  G.ok "#desc passed in #{(Date.now! - start)/1000}s"
  cb! if cb?

function start-mocha cfg, grep, cb
  if _.isFunction grep then [grep, cb] = [void, grep] # variadic
  log \start-mocha, cfg, grep
  cfg <<< firefox-host:env.firefox-host or \localhost
  log cfg
  args = "#MOCHA #MARGS"
  args += " --grep #grep" if grep?
  Cp.spawn \node, (args.split ' '), cwd:Dir.DEV, env:cfg, stdio:[ 0, 1, void ]
    ..on \exit, ->
      cb if it then new Error "Exited with code #it" else void
    ..stderr.on \data, ->
      log s = it.toString!
      # data may be fragmented, so only growl relevant packet
      if /(expected|error|exception)/i.test s
        G.alert (Chalk.stripColor s), nolog:true

function start-site cwd, cfg, cb
  log "start site #{id = cfg.NODE_ENV} #{port = cfg.PORT}"
  args = "#{cfg.NODE_ARGS || ''} boot #id #port".trim!
  return log "unable to start non-existent site at #cwd" unless test \-e, cwd
  Cp.spawn \node, (args.split ' '), cwd:cwd, env:cfg
    ..stderr.on \data, log-data
    ..stdout.on \data, ->
      #log-data it
      cb! if cb and /listening on port/.test it

  function log-data then log Chalk.gray "#{Chalk.underline id} #{it.slice 0, -1}"

function stop-site cfg, cb
  log "stop site #{id = cfg.NODE_ENV} #{port = cfg.PORT}"
  <- kill-node args = "boot #id #port"
  cb!
