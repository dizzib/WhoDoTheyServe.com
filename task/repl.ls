global.log = console.log

Chalk     = require \chalk
Readline  = require \readline
WFib      = require \wait.for .launchFiber
Build     = require \./build
Prod      = require \./prod
Run       = require \./run
Stage     = require \./stage
Stage-seo = require \./stage-seo

const COMMANDS =
  * cmd:'b.fc' desc:'build - files compile'   fn:Build.compile-files
  * cmd:'b.fd' desc:'build - files delete'    fn:Build.delete-files
  * cmd:'b.md' desc:'build - modules delete'  fn:Build.delete-modules
  * cmd:'b.mr' desc:'build - modules refresh' fn:Build.refresh-modules
  * cmd:'b.r ' desc:'build - run'             fn:Run.recycle-build
  * cmd:'s.g ' desc:'stage - generate'        fn:Stage.generate
  * cmd:'s.gs' desc:'stage - generate seo'    fn:Stage-seo.generate
  * cmd:'s.r ' desc:'stage - run'             fn:Run.recycle-staging
  * cmd:'p.l ' desc:'prod  - login'           fn:Prod.login
  * cmd:'p.pu' desc:'prod  - push to live'    fn:Prod.push

rl = Readline.createInterface input:process.stdin, output:process.stdout
  ..setPrompt "wdts q/r >"
  ..prompt!
  ..on \line, (cmd) -> WFib ->
    switch cmd
    | '' =>
      <- Run.cancel-testrun
      rl.prompt!
    | \h =>
      for c in COMMANDS then log "#{Chalk.bold c.cmd} #{c.desc}"
      rl.prompt!
    | \q =>
      Build.stop!
      return rl.close!
    | _  =>
      for c in COMMANDS when cmd is c.cmd.trim! then c.fn!
      rl.prompt!

Build.start on-built:Run.recycle-build
#Build.start!
#Run.recycle-staging!
#Run.recycle-build!
