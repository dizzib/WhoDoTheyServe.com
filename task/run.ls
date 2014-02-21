_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
Cp     = require \child_process
Mg     = require \mongoose
Shell  = require \shelljs/global
Cfg    = require \./config
G      = require \./growl

const API   = "Unit & api tests"
const APP   = "App tests"
const OBJ   = pwd!
const DIS   = OBJ.replace /_build\/obj$/, \_build/dist
const MOCHA = "#OBJ/node_modules/mocha/bin/mocha"
const MARGS = "--reporter spec --bail --recursive"

module.exports =
  cancel-testrun : -> kill-mocha it
  recycle-build  : -> recycle OBJ, Cfg.build
  recycle-staging: -> recycle DIS, Cfg.staging, ' for staging'
  start-staging  : -> start-site DIS, Cfg.staging.master

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

function recycle cwd, g = cfg-group, desc = ''
  [primary, test, tester] = [g.primary, g.test, g.tester]
  <- stop-site primary
  start-site cwd, primary
  G.say "#API#desc starting..."
  <- kill-mocha
  <- stop-site test
  <- drop-db test
  <- start-site cwd, test
  e <- run-tests OBJ, tester, 'app --invert'
  return if e?
  G.ok "#API#desc passed"
  run (-> void)
  #run run
  function run cb
    <- stop-site test
    <- drop-db test
    G.say "#APP#desc starting..."
    <- start-site cwd, test
    e <- run-tests OBJ, tester, 'app'
    G.ok "#APP#desc passed" unless e?
    cb cb

function run-tests cwd, cfg, grep, cb
  if _.isFunction grep then [grep, cb] = [void, grep] # variadic
  log \run-tests, cwd, cfg, grep
  cfg <<< JSON.parse env.tester
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
  log "start site #{id = cfg.NODE_ENV}"
  args = "#{cfg.NODE_ARGS || ''} boot #id".trim!
  Cp.spawn \node, (args.split ' '), cwd:cwd, env:cfg
    ..stderr.on \data, log-data
    ..stdout.on \data, ->
      #log-data it
      cb! if cb and /listening on port/.test it

  function log-data then log Chalk.gray "#{Chalk.underline id} #{it.slice 0, -1}"

function stop-site cfg, cb
  log "stop site #{id = cfg.NODE_ENV}"
  <- kill-node args = "boot #id"
  cb!
