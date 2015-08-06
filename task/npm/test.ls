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
  <- run-suite Test.run.dev_1
  <- run-suite Test.run.dev_2
  process.exit 0

function run-suite fn, cb
  err <- fn site-logging:true
  process.exit err.code or 1 if err
  cb!
