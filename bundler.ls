F    = require \fs
B    = require \browserify
Brfs = require \brfs

exports.init = ->
  libs = # order is important!
    \./app/lib-3p/underscore.mixin.deepExtend
    \./app/lib-3p/backbone-deep-model
    \./app/lib-3p/backbone.routefilter
    \./app/lib-3p/backbone-validation
    \./app/lib-3p/backbone-validation-bootstrap
    \./app/lib-3p/bootstrap/js/bootstrap
    \./app/lib-3p/transparency
    \./app/lib-3p-ext/jquery-3p

  b = B \./app/boot.js
  for l in libs
    b.external l
  b.transform Brfs
  b.require \./app/lib-3p-shim/backbone  , expose:\backbone
  b.require \./app/lib-3p/transparency   , expose:\transparency
  b.require \./app/lib-3p-shim/underscore, expose:\underscore

  err, src <- b.bundle detectGlobals:false
  throw err if err
  err <- F.writeFile \./app/app.js, src
  throw err if err
  console.log 'Bundled app.js'

  return # https://github.com/substack/node-browserify/issues/355

  b = B libs
  for l in libs
    b.require l
  err, src <- b.bundle detectGlobals:false
  throw err if err
  err <- F.writeFile \./app/lib.js, src
  throw err if err
  console.log 'Bundled lib.js'
