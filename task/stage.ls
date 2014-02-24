Assert = require \assert
Chalk  = require \chalk
_      = require \lodash
Shell  = require \shelljs/global
Ug     = require \uglify-js
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod
Dir    = require \./constants .dir
Site   = require \./constants .dir.site
G      = require \./growl

module.exports =
  generate: ->
    try
      mkdir Site.STAGING unless test '-e', Site.STAGING
      pushd Site.STAGING
      delete-files!
      generate-package-json!
      copy-files!
      copy-minified-files!
      set-load-from-cdn!
      copy-seo-files!
      WFor exec, 'npm prune'
      WFor exec, 'npm install'
      G.ok 'generated staging site'
    finally then popd!

## helpers

function copy-minified dir, files
  for f in files
    (Ug.minify "#{Site.DEV}/#dir/#f.js").code.to "#{Site.STAGING}/#dir/#f.js"

function copy-minified-files
  log "copy minified files"
  copy-minified \app, <[ app lib loader ]>
  # CDN fallbacks
  copy-minified \app/lib-3p, <[ backbone backbone-validation d3 jquery jquery.timeago ]>
  copy-minified \app/lib-3p, <[ bootstrap/js/bootstrap-typeahead underscore ]>

function copy-files
  log "copy files to #{Site.STAGING}"
  const FILTER = "'. #{Dir.DEV}/task/stage-files.txt'"
  WFor exec, "rsync -r --filter=#FILTER #{Site.DEV}/ #{Site.STAGING}/"

function copy-seo-files
  void

function delete-files
  log "delete files from #{pwd!}"
  Assert.equal pwd!, Site.STAGING
  WFor exec, "bash -O extglob -O dotglob -c 'rm -rf !(node_modules)'"

function generate-package-json
  log "generating package.json"
  json = require "#{Site.DEV}/package.json"
  delete json.devDependencies
  (JSON.stringify json, void, 2).to "#{Site.STAGING}/package.json"

function set-load-from-cdn
  log "set-load-from-cdn"
  # setting a global flag is more robust than the previous way of using
  # a ?cdn=true querystring which seems to interfere with the window.*
  # support fns in the test runner marionette sandbox
  ("window.isLoadFromCdn = true;" + cat \./app/loader.js).to \./app/loader.js
