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

module.exports =
  cancel-testrun : -> kill-mocha it
  recycle-site-dev          : -> recycle-site DirSite.DEV, Cfg.dev.primary
  recycle-site-dev-tests    : -> recycle-site-tests DirSite.DEV, Cfg.dev
  recycle-site-staging      : -> recycle-site DirSite.STAGING, Cfg.staging.primary
  recycle-site-staging-tests: -> recycle-site-tests DirSite.STAGING, Cfg.staging, ' for staging'

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

function recycle-site cwd, cfg, cb
  <- stop-site cfg
  <- start-site cwd, cfg
  cb! if cb

function recycle-site-tests cwd, cfg, desc = ''
  <- recycle-site cwd, cfg.primary
  run-tests cwd, cfg, desc

function run-tests cwd, cfg, desc
  const API = "Unit & api tests"
  const APP = "App tests"
  [test, tester] = [cfg.test, cfg.tester]
  G.say "#API#desc started"
  <- kill-mocha
  <- stop-site test
  <- drop-db test
  <- start-site cwd, test
  e <- start-mocha Dir.DEV, tester, 'app --invert'
  return if e?
  G.ok "#API#desc passed"
  <- stop-site test
  <- drop-db test
  G.say "#APP#desc started"
  <- start-site cwd, test
  e <- start-mocha Dir.DEV, tester, 'app'
  G.ok "#APP#desc passed" unless e?

function start-mocha cwd, cfg, grep, cb
  if _.isFunction grep then [grep, cb] = [void, grep] # variadic
  log \start-mocha, cwd, cfg, grep
  cfg <<< firefox-host:env.firefox-host or \localhost
  log cfg
  args = "#MOCHA #MARGS"
  args += " --grep #grep" if grep?
  Cp.spawn \node, (args.split ' '), cwd:cwd, env:cfg, stdio:[ 0, 1, void ]
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
