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

Cfg.dev     <<< dirsite:DirSite.DEV
Cfg.staging <<< dirsite:DirSite.STAGING

module.exports =
  cancel           : -> kill-all-mocha ...
  loop-dev-test_2  : -> loop-dev-test_2!
  recycle-dev      : -> recycle-primary Cfg.dev
  recycle-staging  : -> recycle-primary Cfg.staging
  run-dev-test_1   : -> run-test_1 Cfg.dev
  run-dev-test_2   : -> run-test_2 Cfg.dev
  run-dev-tests    : -> run-tests Cfg.dev
  run-staging-tests: -> run-tests Cfg.staging, ' for staging'

## helpers

const GREP_1 = 'app --invert'
const GREP_2 = 'app'
const RX-ERR = /(expected|error|exception)/i

function drop-db cfg, cb
  conn = Mg.createConnection cfg.WDTS_DB_URI
  e <- conn.db.executeDbCommand dropDatabase:1
  throw new Error "drop-db failed: #e" if e
  conn.close!
  cb!

function get-mocha-cmd grep, opts
  cmd = "#{Dir.DEV}/node_modules/mocha/bin/mocha"
  # mocha spawns a _mocha child process
  cmd = cmd.replace '/bin/mocha', '/bin/_mocha' if opts?child
  "#cmd --grep #grep --reporter spec --bail --recursive"

function kill-all-mocha cb
  <- kill-mocha GREP_1
  <- kill-mocha GREP_2
  cb!

function kill-mocha grep, cb
  <- kill-node (get-mocha-cmd grep, child:true)
  <- kill-node (get-mocha-cmd grep)
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
  recycle-tests cfg.test_1, cfg.tester_1, cfg.dirsite, GREP_1, "Unit & api tests#desc"

function run-test_2 cfg, desc = '', cb
  recycle-tests cfg.test_2, cfg.tester_2, cfg.dirsite, GREP_2, "App tests#desc", cb

function recycle-tests test, tester, dirsite, grep, desc, cb
  <- kill-mocha grep
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
  cmd = get-mocha-cmd grep
  Cp.spawn \node, (cmd.split ' '), cwd:Dir.DEV, env:cfg, stdio:[ 0, 1, void ]
    ..on \exit, ->
      cb if it then new Error "Exited with code #it" else void
    ..stderr.on \data, ->
      log s = it.toString!
      # data may be fragmented, so only growl relevant packet
      G.alert (Chalk.stripColor s), nolog:true if RX-ERR.test s

function start-site cwd, cfg, cb
  v = exec 'node --version', silent:true .output.replace '\n', ''
  log "start site #{id = cfg.NODE_ENV}@#{port = cfg.PORT} in node #v"
  args = "boot #id #port".trim!
  return log "unable to start non-existent site at #cwd" unless test \-e, cwd
  Cp.spawn \node, (args.split ' '), cwd:cwd, env:cfg
    ..stderr.on \data, ->
      log-data it
      # data may be fragmented, so only growl relevant packet
      if RX-ERR.test s = it.toString! then G.alert "#id@#port\n#s", nolog:true
    ..stdout.on \data, ->
      #log-data it
      cb! if cb and /listening on port/.test it

  function log-data
    log Chalk.gray "#{Chalk.underline id} #{it.slice 0, -1}"

function stop-site cfg, cb
  log "stop site #{id = cfg.NODE_ENV}@#{port = cfg.PORT}"
  <- kill-node args = "boot #id #port"
  cb!
