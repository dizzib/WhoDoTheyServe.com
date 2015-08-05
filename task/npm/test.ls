global.log = console.log

_     = require \lodash
WFib  = require \wait.for .launchFiber
Build = require \../build
Dir   = require \../constants .dir
Dist  = require \../dist
#Test  = require \../test

cd Dir.BUILD
Build.start!
_.delay run, 1000 # give chokidar time to build its _watched

function run
  <- WFib
  Build.all!
  Build.stop!
  Dist!
  res = 0 #Test.exec!
  process.exit res.code
