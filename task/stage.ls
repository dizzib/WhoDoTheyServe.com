_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
Shell  = require \shelljs/global
Ug     = require \uglify-js
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod

const OBJ = pwd!
const DIS = OBJ.replace /_build\/obj$/, \_build/dist

Assert DIS isnt OBJ
mkdir DIS unless test '-e', DIS

module.exports =
  generate: ->
    try
      pushd DIS
      delete-files!
      copy-files!
      generate-package-json!
      minify-files!
      copy-seo-files!
      WFor exec, 'npm prune'
      WFor exec, 'npm install'
      log Chalk.green 'done!'
    finally then popd!

## helpers

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
  const FNAME = \package.json
  j = require "#OBJ/#FNAME"
  delete j.devDependencies
  (JSON.stringify j, void, 2).to "#DIS/#FNAME"

function minify-files
  minify \app, <[ app lib loader ]>
  # CDN fallbacks
  minify \app/lib-3p, <[ backbone backbone-validation d3 jquery jquery.timeago ]>
  minify \app/lib-3p, <[ bootstrap/js/bootstrap-typeahead underscore ]>

function minify dir, files
  for f in files then (Ug.minify "#OBJ/#dir/#f.js").code.to "#DIS/#dir/#f.js"
