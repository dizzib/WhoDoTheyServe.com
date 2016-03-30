global.log = console.log

Chalk   = require \chalk
_       = require \lodash
Rl      = require \readline
Shell   = require \shelljs/global
WFib    = require \wait.for .launchFiber
Build   = require \./build
Bundle  = require \./bundle
Dir     = require \./constants .dir
Data    = require \./data
Dist    = require \./dist
Flags   = require \./flags
Fntello = require \./fontello
Inst    = require \./npm/install
MaintDE = require \./maint/dead-evidences
MaintEU = require \./maint/evidence-urls
Prod    = require \./prod
Site    = require \./site
Staging = require \./staging
Seo     = require \./seo
Test    = require \./test
G       = require \./growl

const CHALKS = [Chalk.stripColor, Chalk.yellow, Chalk.red]
const COMMANDS =
  * cmd:'h    ' lev:0 desc:'help  - show commands'       fn:show-help
  * cmd:'i.d  ' lev:0 desc:'inst  - delete modules'      fn:Inst.delete-modules
  * cmd:'i.r  ' lev:0 desc:'inst  - refresh modules'     fn:Inst.refresh-modules
  * cmd:'     ' lev:0 desc:'build - halt test run'       fn:Test.cancel
  * cmd:'b    ' lev:0 desc:'build - recycle + test'      fn:-> Test.run \dev
  * cmd:'b.a  ' lev:0 desc:'build - all'                 fn:build-all
  * cmd:'bc   ' lev:0 desc:'build - test coverage $tc'   fn:-> Flags.toggle \test.coverage
  * cmd:'b.b  ' lev:0 desc:'build - bundle'              fn:Bundle.all
  * cmd:'b.d  ' lev:0 desc:'build - delete'              fn:Build.delete
  * cmd:'bl   ' lev:0 desc:'build - site logging $sl'    fn:-> Flags.toggle \site.logging
  * cmd:'b.lt ' lev:0 desc:'build - loop app tests'      fn:-> Test.loop \dev \app
  * cmd:'b1   ' lev:0 desc:'build - enable $api'         fn:-> Flags.toggle \test.run.api
  * cmd:'b2   ' lev:0 desc:'build - enable $app'         fn:-> Flags.toggle \test.run.app
  * cmd:'bt   ' lev:0 desc:'build - autorun tests $ta'   fn:-> Flags.toggle \test.autorun
  * cmd:'d.mde' lev:0 desc:'dev   - maintain dead evs'   fn:MaintDE.dev
  * cmd:'f.o  ' lev:0 desc:'fonts - open fontello'       fn:Fntello.open
  * cmd:'f.s  ' lev:0 desc:'fonts - save fontello'       fn:Fntello.save
  * cmd:'s    ' lev:0 desc:'stage - recycle + test'      fn:-> Test.run \staging
  * cmd:'s.mu ' lev:0 desc:'stage - maint: fix ev urls'  fn:MaintEU.staging
  * cmd:'s.g  ' lev:1 desc:'stage - generate + test'     fn:generate-staging
  * cmd:'s.gs ' lev:1 desc:'stage - generate seo'        fn:Seo.generate
  * cmd:'s.mde' lev:1 desc:'stage - maintain dead evs'   fn:MaintDE.staging
  * cmd:'p    ' lev:0 desc:'prod  - show config'         fn:Prod.show-cfg
# * cmd:'p.l  ' lev:1 desc:'prod  - login'               fn:Prod.af.login
  * cmd:'p.ld ' lev:0 desc:'PROD  - list deployments'    fn:Prod.rhc.deployments.list
  * cmd:'p.le ' lev:0 desc:'PROD  - list env vars'       fn:Prod.rhc.env.list
  * cmd:'p.mde' lev:1 desc:'prod  - maintain dead evs'   fn:MaintDE.prod
  * cmd:'p.mu ' lev:1 desc:'prod  - maint: fix ev urls'  fn:MaintEU.prod
  * cmd:'p.AD ' lev:2 desc:'PROD  - activate deployment' fn:Prod.rhc.deployments.activate
  * cmd:'p.ENV' lev:2 desc:'PROD  - env vars->PROD'      fn:Prod.rhc.env.send
# * cmd:'p.UPD' lev:2 desc:'prod  - update stage->PROD'  fn:Prod.af.update
  * cmd:'d    ' lev:0 desc:'data  - show config'         fn:Data.show-cfg
  * cmd:'d.ba ' lev:0 desc:'DATA  - PROD->bak'           fn:Data.dump-prod-to-backup
  * cmd:'d.s2b' lev:0 desc:'data  - stage->bak'          fn:Data.dump-stage-to-backup
  * cmd:'d.st ' lev:1 desc:'data  - bak->stage'          fn:Data.restore-backup-to-staging
  * cmd:'d.B2P' lev:2 desc:'DATA  - bak->PROD'           fn:Data.restore-backup-to-prod

init-shelljs!
cd Dir.BUILD # for safety set working directory to build

for c in COMMANDS
  c.disabled = (c.cmd.0 is \d and not Data.enabled!) or (c.cmd.0 is \p and not Prod.enabled!)
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

Build
  ..on \built ->
    Dist!
    Site.recycle.dev!
  ..on \built-api -> Test.run \dev \api if Flags.get!test.autorun
  ..on \built-app -> Test.run \dev \app if Flags.get!test.autorun
  ..start!
Flags
  ..on \toggle show-help
Site
  ..recycle.dev!
  ..recycle.staging!

_.delay show-help, 1500ms
_.delay (-> rl.prompt!), 1750ms

# helpers

function build-all
  try Build.all!
  catch e then G.err e

function generate-staging
  Staging.generate!
  Site.recycle.staging!
  Test.run \staging

function init-shelljs
  config.fatal  = true # shelljs doesn't raise exceptions, so set this process to die on error
  config.silent = true # otherwise too much noise
  exec-orig = global.exec
  global.exec = (cmd, opts, cb) -> # make exec noisy unless explicitly silenced
    [cb = opts, opts = silent:false] if _.isFunction opts
    exec-orig cmd, opts, cb

function show-help
  function get-flag-desc then if it then Chalk.bold.green \yes else Chalk.bold.cyan \no
  function get-run-tests-desc then "#it tests #{get-flag-desc Flags.get!test.run[it]}"
  f = Flags.get!
  flag-vals =
    api: get-run-tests-desc \api
    app: get-run-tests-desc \app
    sl : get-flag-desc f.site.logging
    ta : get-flag-desc f.test.autorun
    tc : get-flag-desc f.test.coverage
  for c in COMMANDS when !c.disabled
    s = c.display
    for k, v of flag-vals then s = s.replace "$#k" v
    log s

