_     = require \lodash
Chalk = require \chalk
Cp    = require \child_process
Mg    = require \mongoose
Shell = require \shelljs/global
Cfg   = require \./config
Growl = require \./growl

const MOCHA  = "#{pwd!}/node_modules/mocha/bin/mocha"
const TESTER = "#MOCHA --reporter dot --bail --recursive"

g = void

module.exports =
  init: (cb) ->
    e, tmp <- Growl.get
    g := tmp
    cb e

  recycle: ->
    const API = "Unit & api tests"
    const APP = "App tests"
    <- stop-site Cfg.dev
    start-site Cfg.dev
    g.say "#API starting..."
    # mocha spawns a child process which we must also kill
    <- kill-node MOCHA.replace '/bin/mocha', '/bin/_mocha'
    <- kill-node MOCHA
    <- stop-site Cfg.test
    <- drop-db Cfg.test
    <- start-site Cfg.test
    e <- run-tests 'app --invert'
    return if e?
    g.ok "#API passed"
    <- stop-site Cfg.test
    <- drop-db Cfg.test
    g.say "#APP starting..."
    <- start-site Cfg.test
    e <- run-tests 'app'
    g.ok "#APP passed" unless e?

function drop-db cfg, cb
  Mg.connect cfg.WDTS_DB_URI
  e <- Mg.connection.db.executeDbCommand dropDatabase:1
  throw new Error "drop-db failed: #e" if e
  Mg.disconnect!
  cb!

function kill-node args, cb
  code, out <- exec cmd = "pkill -ef 'node #args'"
  # 0 One or more processes matched the criteria. 
  # 1 No processes matched. 
  # 2 Syntax error in the command line. 
  # 3 Fatal error: out of memory etc. 
  throw new Error "#cmd returned #code" if code > 1
  cb!

function start-site cfg, cb
  log "start site #{id = cfg.NODE_ENV}"
  Cp.spawn \node, [ \boot id ], env:cfg
    ..stderr.on \data, log-data
    ..stdout.on \data, ->
      #log-data it
      cb! if cb and /listening on port/.test it

  function log-data then log Chalk.gray "#{Chalk.underline id} #{it.slice 0, -1}"

function run-tests grep, cb
  log \run-tests, grep
  cfg = Cfg.tester <<< JSON.parse env.tester
  args = "#TESTER --grep #grep"
  Cp.spawn \node, (args.split ' '), env:cfg, stdio:[ 0, 1, void ]
    ..on \exit, ->
      cb if it then new Error "Exited with code #it" else void
    ..stderr.on \data, ->
      log s = it.toString!
      # data may be fragmented, so only growl relevant packet
      if /(expected|error|exception)/i.test s
        g.alert (Chalk.stripColor s), nolog:true

function stop-site cfg, cb
  log "stop site #{id = cfg.NODE_ENV}"
  <- kill-node args = "boot #id"
  cb!
