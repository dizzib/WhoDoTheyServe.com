F  = require \fs
B  = require \browserify
BF = require \brfs

exports.init = ->
  libs =
    # execution order is random
    # https://github.com/substack/node-browserify/issues/355
    \./app/lib-3p/underscore.mixin.deepExtend
    \./app/lib-3p/backbone-deep-model
    \./app/lib-3p/backbone.routefilter
    \./app/lib-3p/backbone-validation-bootstrap
    \./app/lib-3p/bootstrap/js/bootstrap
    \./app/lib-3p/insert-css
    \./app/lib-3p/transparency
    \./app/lib-3p-ext/jquery

  ba = B \./app/boot.js
  for l in libs
    ba.external l
  ba.transform BF
  ba.require \./app/lib-3p-shim/backbone  , expose:\backbone
  ba.require \./app/lib-3p/transparency   , expose:\transparency
  ba.require \./app/lib-3p-shim/underscore, expose:\underscore

  wsa = F.createWriteStream \./app/app.js
  rsa = ba.bundle detectGlobals:false, insertGlobals:false
  rsa.on \end, -> console.log 'Bundled app.js'
  rsa.pipe wsa

  bl = B libs
  for l in libs
    bl.require l
  wsl = F.createWriteStream \./app/lib.js
  rsl = bl.bundle detectGlobals:false, insertGlobals:false
  rsl.on \end, -> console.log 'Bundled lib.js'
  rsl.pipe wsl
