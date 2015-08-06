global.log = console.log

WFib  = require \wait.for .launchFiber
Build = require \../build
Dir   = require \../constants .dir
Dist  = require \../dist
Test  = require \../test

cd Dir.BUILD
Build.start!
setTimeout run, 1000 # give chokidar time to build its _watched

function run
  <- WFib
  Build.all!
  Build.stop!
  Dist!
  err <- Test.exec
  process.exit if err then (err.code or 1) else 0
