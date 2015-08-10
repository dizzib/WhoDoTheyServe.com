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
  err <- Test.run \dev \api
  process.exit err.code or 1 if err
  err <- Test.run \dev \app
  process.exit err.code or 1 if err
  process.exit 0
