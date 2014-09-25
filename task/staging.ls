Assert = require \assert
Chalk  = require \chalk
_      = require \lodash
Shell  = require \shelljs/global
Ug     = require \uglify-js
W4     = require \wait.for .for
W4m    = require \wait.for .forMethod
Build  = require \./constants .dir.build
G      = require \./growl

module.exports =
  generate: ->
    try
      mkdir Build.STAGING unless test '-e', Build.STAGING
      pushd Build.STAGING
      delete-files!
      generate-package-json!
      copy-files!
      copy-minified-files!
      set-load-from-cdn!
      copy-seo-files!
      W4 exec, 'npm prune'
      W4 exec, 'npm install'
      G.ok 'generated staging site'
    finally then popd!

## helpers

function copy-minified dir, files
  for f in files
    (Ug.minify "#{Build.dev.SITE}/#dir/#f.js").code.to "#{Build.STAGING}/#dir/#f.js"

function copy-minified-files
  log "copy minified files"
  copy-minified \app, <[ app lib loader ]>
  copy-minified \app/lib-3p, <[ backbone d3 jquery underscore ]> # CDN fallbacks

function copy-files
  log "copy files to #{Build.STAGING}"
  const FILTER = "'. #{Build.DEV}/task/staging-files.txt'"
  W4 exec, "rsync -r --filter=#FILTER #{Build.dev.SITE}/ #{Build.STAGING}/"

function copy-seo-files
  const N-MIN = 300
  try
    pushd Build.SEO
    n = (W4 exec, "ls -1R | grep .*.html | wc -l").split('\n').0
    log "copy #n seo files"
    G.alert "too few seo files: actual=#n, expecting >= #N-MIN" if n < N-MIN
    cp \-r, "#{Build.SEO}/*", "#{Build.STAGING}/app"
  finally then popd!

function delete-files
  log "delete files from #{pwd!}"
  Assert.equal pwd!, Build.STAGING
  W4 exec, "bash -O extglob -O dotglob -c 'rm -rf !(node_modules)'"

function generate-package-json
  log "generating package.json"
  json = require "#{Build.dev.SITE}/package.json"
  delete json.devDependencies
  (JSON.stringify json, void, 2).to "#{Build.STAGING}/package.json"

function set-load-from-cdn
  log "set-load-from-cdn"
  # setting a global flag is more robust than the previous way of using
  # a ?cdn=true querystring which seems to interfere with the window.*
  # support fns in the test runner marionette sandbox
  ("window.isLoadFromCdn = true;" + cat \./app/loader.js).to \./app/loader.js
