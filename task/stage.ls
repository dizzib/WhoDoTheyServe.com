_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
Shell  = require \shelljs/global
Ug     = require \uglify-js
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod
G      = require \./growl

const OBJ = pwd!
const DIS = OBJ.replace /_build\/obj$/, \_build/dist

Assert DIS isnt OBJ
mkdir DIS unless test '-e', DIS

# shelljs doesn't seem to raise exceptions. Next best thing is for this
# process to die on error
config.fatal = true

module.exports =
  generate: ->
    try
      pushd DIS
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
  for f in files then (Ug.minify "#OBJ/#dir/#f.js").code.to "#DIS/#dir/#f.js"

function copy-minified-files
  log "copy minified files"
  copy-minified \app, <[ app lib loader ]>
  # CDN fallbacks
  copy-minified \app/lib-3p, <[ backbone backbone-validation d3 jquery jquery.timeago ]>
  copy-minified \app/lib-3p, <[ bootstrap/js/bootstrap-typeahead underscore ]>

function copy-files
  log "copy files to #DIS"
  WFor exec, "rsync -r --filter='. #OBJ/task/stage-files.txt' #OBJ/ #DIS/"

function copy-seo-files
  void

function delete-files
  log "delete files from #{pwd!}"
  Assert.equal pwd!, DIS
  WFor exec, "bash -O extglob -O dotglob -c 'rm -rf !(node_modules)'"

function generate-package-json
  log "generating package.json"
  const FNAME = \package.json
  j = require "#OBJ/#FNAME"
  delete j.devDependencies
  (JSON.stringify j, void, 2).to "#DIS/#FNAME"

function set-load-from-cdn
  log "set-load-from-cdn"
  # setting a global flag is more robust than the previous way of using
  # a ?cdn=true querystring which seems to interfere with the window.*
  # suppoert fns in the test runner marionette sandbox
  ("window.isLoadFromCdn = true;" + cat \./app/loader.js).to \./app/loader.js
