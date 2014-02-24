global.log = console.log

Chalk = require \chalk
Rl    = require \readline
Shell = require \shelljs/global
WFib  = require \wait.for .launchFiber
Build = require \./build
Data  = require \./data
Prod  = require \./prod
Run   = require \./run
Stage = require \./stage
Seo   = require \./seo

# shelljs doesn't seem to raise exceptions. Next best thing is for this
# process to die on error
config.fatal = true

const COMMANDS =
  * cmd:'h    ' lev:0 desc:'help  - show commands'  fn:show-help
  * cmd:'b    ' lev:0 desc:'build - recycle + test' fn:Run.recycle-site-tests-dev
  * cmd:'b.fc ' lev:0 desc:'build - files compile'  fn:Build.compile-files
  * cmd:'b.fd ' lev:0 desc:'build - files delete'   fn:Build.delete-files
  * cmd:'b.nd ' lev:0 desc:'build - npm delete'     fn:Build.delete-modules
  * cmd:'b.nr ' lev:0 desc:'build - npm refresh'    fn:Build.refresh-modules
  * cmd:'s    ' lev:0 desc:'stage - recycle + test' fn:Run.recycle-site-tests-staging
  * cmd:'s.g  ' lev:1 desc:'stage - generate'       fn:Stage.generate
  * cmd:'s.gs ' lev:1 desc:'stage - generate seo'   fn:Seo.generate
  * cmd:'p    ' lev:0 desc:'prod  - show config'    fn:Prod.show-config
  * cmd:'p.l  ' lev:1 desc:'prod  - login'          fn:Prod.login
  * cmd:'p.s2p' lev:2 desc:'prod  - staging ->PROD' fn:Prod.push
# * cmd:'p.env' lev:2 desc:'prod  - env vars->PROD' fn:Prod.send-env-vars
  * cmd:'d    ' lev:0 desc:'data  - show config'    fn:Data.show-config
  * cmd:'d.ba ' lev:0 desc:'data  - PROD->bak'      fn:Data.dump-prod-to-backup
  * cmd:'d.st ' lev:1 desc:'data  - bak->staging'   fn:Data.restore-backup-to-staging
# * cmd:'d.b2p' lev:2 desc:'data  - bak->PROD'      fn:Data.restore-backup-to-prod

const CHALKS = [Chalk.stripColor, Chalk.yellow, Chalk.red]
for c in COMMANDS
  c.disabled = (c.cmd.0 is \d and not Data.is-cfg!) or (c.cmd.0 is \p and not Prod.is-cfg!)
  c.display = "#{Chalk.bold CHALKS[c.lev] c.cmd} #{c.desc}"

rl = Rl.createInterface input:process.stdin, output:process.stdout
  ..setPrompt "wdts >"
  ..prompt!
  ..on \line, (cmd) -> WFib ->
    switch cmd
    | '' =>
      <- Run.cancel-testrun
      rl.prompt!
    | _  =>
      for c in COMMANDS when cmd is c.cmd.trim! then c.fn!
      rl.prompt!

Build.start on-built:Run.recycle-site-tests-dev
Run.recycle-site-dev!
Run.recycle-site-staging!
setTimeout ->
  show-help!
  rl.prompt!
, 500ms

function show-help
  for c in COMMANDS when !c.disabled then log c.display
