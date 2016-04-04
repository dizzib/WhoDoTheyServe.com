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
    mkdir \-p Dir.dist.STAGING unless test \-e Dir.dist.STAGING
    try
      pushd Dir.dist.STAGING
      delete-files!
      copy-files!
      copy-minified-files!
      set-load-from-cdn!
      copy-seo-files!
      W4 exec, 'npm prune'
      W4 exec, 'npm install'
      # shrinkwrap ensures exact staging dependency tree gets deployed,
      # otherwise there's a small risk of breakage in production
      W4 exec, 'npm shrinkwrap'
      return 'shrinkwrap failed' unless test \-e \npm-shrinkwrap.json
      G.ok 'generated staging site'
    finally then popd!

## helpers

function copy-minified dir, files
  for f in files
    (Ug.minify "#{Dir.build.SITE}/#dir/#f.js").code.to "#{Dir.dist.STAGING}/#dir/#f.js"

function copy-minified-files
  log "copy minified files"
  copy-minified \app <[ app lib lib-signin ]>
  copy-minified \app/lib-3p <[ backbone d3 jquery underscore ]> # CDN fallbacks

function copy-files
  log "copy files to #{Dir.dist.STAGING}"
  const FILTER = "'. #{Dir.build.TASK}/staging-files.txt'"
  W4 exec, "rsync -r --filter=#FILTER #{Dir.build.SITE}/ #{Dir.dist.STAGING}/"

function copy-seo-files
  return G.alert 'no seo' unless test \-e Dir.dist.SEO
  const N-MIN = 700
  try
    pushd Dir.dist.SEO
    n = (W4 exec, "ls -1R | grep .*.html | wc -l").split('\n').0
    log "copy #n seo files"
    G.alert "too few seo files: actual=#n, expecting >= #N-MIN" if n < N-MIN
    cp \-r "#{Dir.dist.SEO}/*" "#{Dir.dist.STAGING}/app"
  finally then popd!

function delete-files
  Assert.equal pwd!, Dir.dist.STAGING
  log "delete files from #{pwd!}"
  W4 exec, "bash -O extglob -c 'rm -rf !(.|..|.git*|.openshift|node_modules)'"

function set-load-from-cdn
  log "set-load-from-cdn"
  # setting a flag is more robust than the previous way of using
  # a ?cdn=true querystring which seems to interfere with the window.*
  # support fns in the test runner marionette sandbox
  const PATH = \./app/index.html
  const VAR  = \window.isLoadFromCdn
  cat PATH .replace("#VAR = false" "#VAR = true").to PATH
