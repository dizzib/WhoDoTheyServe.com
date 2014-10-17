global.log = console.log

Chalk   = require \chalk
_       = require \lodash
Rl      = require \readline
Shell   = require \shelljs/global
WFib    = require \wait.for .launchFiber
Build   = require \./build
Bundle  = require \./bundle
DirBld  = require \./constants .dir.build
Data    = require \./data
MaintDE = require \./maint/dead-evidences
Prod    = require \./prod
Run     = require \./run
Staging = require \./staging
Seo     = require \./seo
G       = require \./growl

const CHALKS = [Chalk.stripColor, Chalk.yellow, Chalk.red]
const COMMANDS =
  * cmd:'h    ' lev:0 desc:'help  - show commands'      fn:show-help
  * cmd:'     ' lev:0 desc:'build - halt test run'      fn:Run.cancel
  * cmd:'b    ' lev:0 desc:'build - recycle + test'     fn:run-dev-tests
  * cmd:'b.all' lev:0 desc:'build - all'                fn:Build.all
  * cmd:'b.b  ' lev:0 desc:'build - bundle'             fn:Bundle.all
  * cmd:'b.fd ' lev:0 desc:'build - files delete'       fn:Build.delete-files
  * cmd:'b.la ' lev:0 desc:'build - loop app tests'     fn:-> Run.loop-dev-test_2 flags
  * cmd:'b.nd ' lev:0 desc:'build - npm delete'         fn:Build.delete-modules
  * cmd:'b.nr ' lev:0 desc:'build - npm refresh'        fn:Build.refresh-modules
  * cmd:'b.sl ' lev:0 desc:'build - site logging $sl'   fn:-> toggle-flag \siteLogging
  * cmd:'b.t  ' lev:0 desc:'build - autorun tests $ta'  fn:-> toggle-flag \autorunTests
  * cmd:'b.t1 ' lev:0 desc:'build - toggle $api'        fn:-> toggle-run-tests \api
  * cmd:'b.t2 ' lev:0 desc:'build - toggle $app'        fn:-> toggle-run-tests \app
  * cmd:'b.tc ' lev:0 desc:'build - test coverage $tc'  fn:-> toggle-flag \testCoverage
  * cmd:'d.mde' lev:0 desc:'dev   - maintain dead evs'  fn:MaintDE.dev
  * cmd:'s    ' lev:0 desc:'stage - recycle + test'     fn:-> Run.run-staging-tests flags
  * cmd:'s.g  ' lev:1 desc:'stage - generate + test'    fn:generate-staging
  * cmd:'s.gs ' lev:1 desc:'stage - generate seo'       fn:Seo.generate
  * cmd:'s.mde' lev:1 desc:'stage - maintain dead evs'  fn:MaintDE.staging
  * cmd:'p    ' lev:0 desc:'prod  - show config'        fn:Prod.show-config
  * cmd:'p.l  ' lev:1 desc:'prod  - login'              fn:Prod.login
  * cmd:'p.mde' lev:1 desc:'prod  - maintain dead evs'  fn:MaintDE.prod
  * cmd:'p.UPD' lev:2 desc:'prod  - update stage->PROD' fn:Prod.update
  * cmd:'p.ENV' lev:2 desc:'prod  - env vars->PROD'     fn:Prod.send-env-vars
  * cmd:'d    ' lev:0 desc:'data  - show config'        fn:Data.show-config
  * cmd:'d.ba ' lev:0 desc:'data  - PROD->bak'          fn:Data.dump-prod-to-backup
  * cmd:'d.s2b' lev:0 desc:'data  - stage->bak'         fn:Data.dump-stage-to-backup
  * cmd:'d.st ' lev:1 desc:'data  - bak->stage'         fn:Data.restore-backup-to-staging
  * cmd:'d.B2P' lev:2 desc:'data  - bak->PROD'          fn:Data.restore-backup-to-prod

const FLAGS-PATH = "#{DirBld.dev.TASK}/flags.json"
const FLAGS-DEFAULT =
  autorun-tests: true
  test-coverage: false
  site-logging : false
  run-tests    : api:true app:true

init-shelljs!
cd DirBld.DEV # for safety, set working directory to dev build
flags = load-flags!

for c in COMMANDS
  c.disabled = (c.cmd.0 is \d and not Data.is-cfg!) or (c.cmd.0 is \p and not Prod.is-cfg!)
  c.display = "#{Chalk.bold CHALKS[c.lev] c.cmd} #{c.desc}"

rl = Rl.createInterface input:process.stdin, output:process.stdout
  ..setPrompt "wdts >"
  ..on \line, (cmd) ->
    <- WFib
    rl.pause!
    for c in COMMANDS when cmd is c.cmd.trim!
      try c.fn rl # readline is DI'd because multiple instances causes odd behaviour
      catch e then log e
    rl.resume!
    rl.prompt!

Build.on \built, -> Run.recycle-dev flags
Build.on \built-api, -> run-tests \api, Run.run-dev-test_1 if flags.autorun-tests
Build.on \built-app, -> run-tests \app, Run.run-dev-test_2 if flags.autorun-tests
Build.start!
Run.recycle-dev flags
Run.recycle-staging flags

_.delay show-help, 1500ms
_.delay (-> rl.prompt!), 1750ms

# helpers

function generate-staging
  Staging.generate!
  Run.recycle-staging flags
  Run.run-staging-tests flags

function load-flags
  try
    return JSON.parse(cat FLAGS-PATH) if test \-e, FLAGS-PATH
    FLAGS-DEFAULT
  catch
    FLAGS-DEFAULT

function get-flag-desc
  "(#{if it then Chalk.bold.green \yes else Chalk.bold.cyan \no})"

function get-run-tests-desc
  "#it tests #{get-flag-desc flags.run-tests[it]}"

function init-shelljs
  config.fatal  = true # shelljs doesn't raise exceptions, so set this process to die on error
  config.silent = true # otherwise too much noise
  exec-orig = global.exec
  global.exec = (cmd, opts, cb) -> # make exec noisy unless explicitly silenced
    [cb = opts, opts = silent:false] if _.isFunction opts
    exec-orig cmd, opts, cb

function run-dev-tests
  run-tests \api, Run.run-dev-test_1
  run-tests \app, Run.run-dev-test_2

function run-tests id, fn
  if flags.run-tests[id] then (fn flags) else log Chalk.cyan "skip #id tests"

function save-flags
  (JSON.stringify flags).to FLAGS-PATH

function show-help
  flag-vals =
    api: get-run-tests-desc \api
    app: get-run-tests-desc \app
    sl : get-flag-desc flags.site-logging
    ta : get-flag-desc flags.autorun-tests
    tc : get-flag-desc flags.test-coverage
  for c in COMMANDS when !c.disabled
    s = c.display
    for k, v of flag-vals then s = s.replace "$#k", v
    log s

function toggle-run-tests
  (s = flags.run-tests)[it] = not s[it]
  save-flags!
  show-help!

function toggle-flag
  flags[it] = not (flags[it] or false)
  save-flags!
  show-help!
