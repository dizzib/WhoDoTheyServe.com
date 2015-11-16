Browsify = require \browserify
Brfs     = require \brfs
Cacheify = require \cacheify # reduces bundle time from 1.5 to 0.3 secs!
Exposify = require \exposify
Fs       = require \fs
LevelUp  = require \levelup
_        = require \lodash
Memdown  = require \memdown
Shell    = require \shelljs/global
W4       = require \wait.for .for
Dir      = require \./constants .dir
Dirname  = require \./constants .dirname
G        = require \./growl

const LIBS =
  # bundle order is random: https://github.com/substack/node-browserify/issues/355
  # UPDATE: this now appears to be fixed in browserify, so files get bundled in the correct order.
  \./lib-3p/underscore.mixin.deepExtend
  \./lib-3p/Autolinker
  \./lib-3p/backbone-deep-model
  \./lib-3p/backbone-validation
  \./lib-3p/backbone-validation-bootstrap
  \./lib-3p/bootstrap/js/bootstrap-dropdown
  \./lib-3p/bootstrap/js/bootstrap-typeahead
  \./lib-3p/bootstrap-combobox
  \./lib-3p/jquery.bootstrap-dropdown-hover
  \./lib-3p/jquery.multiple.select
  \./lib-3p/jquery.timeago
  \./lib-3p/transparency
  \./lib-3p-ext/jquery

cache = brfs:(LevelUp Memdown), exposify:LevelUp Memdown
Exposify.config = backbone:\Backbone underscore:\_

module.exports = me =
  all: ->
    me.app!
    me.css!
    me.lib!
  app: (opath) ->
    bundle \app.js, ->
      # Cacheify has no concept of dependencies so we must ensure an update to a brfs'd
      # file invalidates its parent js. Quick and dirty method is to clear the whole cache!
      if /\.(html|css)$/.test opath # file types which can be brfs'd
        log "cache invalidated by #opath"
        cache.brfs = LevelUp Memdown
        cache.exposify = LevelUp Memdown
      b = Browsify \./boot.js
        ..require \./lib-3p/Autolinker  , expose:\Autolinker
        ..require \./lib-3p/transparency, expose:\transparency
        ..transform Cacheify Exposify, cache.exposify
        ..transform Cacheify Brfs, cache.brfs
      for l in LIBS then b.external l
      b
  css: ->
    pushd "#{Dir.build.SITE}/app"
    try
      const DEST = \app.css
      const EXCLUDES =
        /^lib-3p\/bootstrap\//
        /^lib-3p\/font-awesome/
        /^lib-3p\/multiple-select/
        /^theme/
      rm DEST if test \-e, DEST
      files = (find \.).filter -> it.match /\.css$/
      for rx in EXCLUDES then files .= filter -> not it.match rx
      css = cat files
      css.to DEST
      size = Math.floor css.length / 1024
      G.say "Bundled #DEST (#{size}k) from #{files.length} files"
    finally
      popd!
  is-lib: (ipath) ->
    ipath-app = ipath.replace "#{Dirname.SITE}/app/", './'
    _.any LIBS, -> _.contains ipath-app, it
  lib: ->
    bundle \lib.js, ->
      b = Browsify LIBS
      for l in LIBS then b.require l
      b

## helpers

function bundle path, fn-setup
  pushd "#{Dir.build.SITE}/app"
  try
    W4 (cb) ->
      t0 = process.hrtime!
      b = fn-setup!
      out = Fs.createWriteStream path
        ..on \finish, ->
          t = process.hrtime t0
          size = Math.floor out.bytesWritten / 1024
          G.say "Bundled #path (#{size}k) in #{t.0}.#{t.1}s"
          G.alert "#path is too large!" if size > 200k
          cb!
      b.bundle detectGlobals:false, insertGlobals:false
        ..on \error, ->
          G.alert "Bundle error: #{it.message}"
          cb!
        ..pipe out
  finally
    popd!
