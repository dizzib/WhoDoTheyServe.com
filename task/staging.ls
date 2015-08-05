Assert = require \assert
Chalk  = require \chalk
_      = require \lodash
Shell  = require \shelljs/global
Ug     = require \uglify-js
W4     = require \wait.for .for
W4m    = require \wait.for .forMethod
Dir    = require \./constants .dir
G      = require \./growl

module.exports =
  generate: ->
    try
      mkdir \-p Dir.dist.STAGING unless test \-e Dir.dist.STAGING
      pushd Dir.dist.STAGING
      delete-files!
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
    (Ug.minify "#{Dir.build.dev.SITE}/#dir/#f.js").code.to "#{Dir.dist.STAGING}/#dir/#f.js"

function copy-minified-files
  log "copy minified files"
  copy-minified \app, <[ app lib loader ]>
  copy-minified \app/lib-3p, <[ backbone d3 jquery underscore ]> # CDN fallbacks

function copy-files
  log "copy files to #{Dir.dist.STAGING}"
  const FILTER = "'. #{Dir.build.DEV}/task/staging-files.txt'"
  W4 exec, "rsync -r --filter=#FILTER #{Dir.build.dev.SITE}/ #{Dir.dist.STAGING}/"

function copy-seo-files
  return G.alert 'no seo' unless test \-e Dir.dist.SEO
  const N-MIN = 300
  try
    pushd Dir.dist.SEO
    n = (W4 exec, "ls -1R | grep .*.html | wc -l").split('\n').0
    log "copy #n seo files"
    G.alert "too few seo files: actual=#n, expecting >= #N-MIN" if n < N-MIN
    cp \-r "#{Dir.dist.SEO}/*" "#{Dir.dist.STAGING}/app"
  finally then popd!

function delete-files
  log "delete files from #{pwd!}"
  Assert.equal pwd!, Dir.dist.STAGING
  W4 exec, "bash -O extglob -O dotglob -c 'rm -rf !(node_modules)'"

function set-load-from-cdn
  log "set-load-from-cdn"
  # setting a global flag is more robust than the previous way of using
  # a ?cdn=true querystring which seems to interfere with the window.*
  # support fns in the test runner marionette sandbox
  ("window.isLoadFromCdn = true;" + cat \./app/loader.js).to \./app/loader.js
