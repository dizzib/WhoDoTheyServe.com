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
    \./app/lib-3p/insert-css
    \./app/lib-3p/jquery.timeago
    \./app/lib-3p/transparency
    \./app/lib-3p-ext/jquery-3p

  ba = B \./app/boot.js
  for l in libs
    ba.external l
  ba.transform Brfs
  ba.require \./app/lib-3p-shim/backbone  , expose:\backbone
  ba.require \./app/lib-3p/transparency   , expose:\transparency
  ba.require \./app/lib-3p-shim/underscore, expose:\underscore

  wsa = F.createWriteStream \./app/app.js
  rsa = ba.bundle detectGlobals:false, insertGlobals:false
  rsa.on \end, -> console.log 'Bundled app.js'
  rsa.pipe wsa

  return # https://github.com/substack/node-browserify/issues/355

  bl = B libs
  for l in libs
    bl.require l
  wsl = F.createWriteStream \./app/lib.js
  rsl = bl.bundle detectGlobals:false, insertGlobals:false
  rsl.on \end, -> console.log 'Bundled lib.js'
  rsl.pipe wsl
