_      = require \lodash
Assert = require \assert
Brsify = require \browserify
Brfs   = require \brfs
Cron   = require \cron
Fs     = require \fs
Gaze   = require \gaze
Md     = require \marked
Path   = require \path
Shell  = require \shelljs/global
WFib   = require \wait.for .launchFiber
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod
Growl  = require \./growl

const BUILD    = \_build
const BUILDOBJ = "#BUILD/obj"
const NMODULES = './node_modules'
const ROOT     = pwd!replace "/#BUILDOBJ", ''

g      = void
opts   = on-built: ->
pruner = new Cron.CronJob cronTime:'*/10 * * * *', onTick:prune-empty-dirs
tasks  =
  jade:
    cmd : "#NMODULES/jade/bin/jade --out $OUT $IN"
    ixt : \jade
    oxt : \html
    mixn: \_
  livescript:
    cmd : "#NMODULES/LiveScript/bin/lsc --output $OUT $IN"
    ixt : \ls
    oxt : \js
    xsub: 'json.js->json'
  markdown:
    cmd : markdown
    ixt : \md
    oxt : \html
  static:
    cmd : 'cp $IN $OUT'
    ixt : '+(css|gif|html|jpg|js|json|pem|png|svg|ttf|woff|nodemonignore)'
  stylus:
    cmd : "#NMODULES/stylus/bin/stylus -u nib --out $OUT $IN"
    ixt : \styl
    oxt : \css
    mixn: \_

log pwd!
log ROOT

module.exports =
  clean-files: -> WFib ->
    log "clean-files #{pwd!}"
    Assert _.contains pwd!, BUILDOBJ
    WFor exec, "bash -O extglob -O dotglob -c 'rm -rf !(node_modules|task)'"

  clean-modules: ->
    log "clean-modules #{pwd!}"
    Assert _.contains pwd!, BUILDOBJ
    rm '-rf' "./node_modules"

  compile-all: ->
    try WFib ->
      for tid of tasks then compile-batch tid
      prepare!
    catch e then g.err e

  init: (o, cb) ->
    opts := o
    e, tmp <- Growl.get
    g := tmp
    cb e

  npm-refresh: -> WFib ->
    WFor exec, 'npm prune'
    WFor exec, 'npm install'

  start: ->
    try
      pushd ROOT
      for tid of tasks then start-watching tid
    finally
      popd!
    pruner.start!
    g.say 'build started'

  stop: ->
    pruner.stop!
    for , t of tasks then t.gaze?close!
    g.say 'build stopped'

## helpers

function bundle-app
  const LIBS =
    # execution order is random
    # https://github.com/substack/node-browserify/issues/355
    \./lib-3p/underscore.mixin.deepExtend
    \./lib-3p/backbone-deep-model
    \./lib-3p/backbone.routefilter
    \./lib-3p/backbone-validation-bootstrap
    \./lib-3p/bootstrap-combobox
    \./lib-3p/insert-css
    \./lib-3p/transparency
    \./lib-3p-ext/jquery
  try
    pushd "./app"
    ba = Brsify \./boot.js
    for l in LIBS then ba.external l
    ba.transform Brfs
    ba.require \./lib-3p/transparency   , expose:\transparency
    ba.require \./lib-3p-shim/backbone  , expose:\backbone
    ba.require \./lib-3p-shim/underscore, expose:\underscore

    osa = Fs.createWriteStream \app.js
    isa = ba.bundle detectGlobals:false, insertGlobals:false
    isa.on \end, -> g.say 'Bundled app.js'
    isa.pipe osa

    bl = Brsify LIBS
    for l in LIBS then bl.require l
    osl = Fs.createWriteStream \lib.js
    isl = bl.bundle detectGlobals:false, insertGlobals:false
    isl.on \end, -> g.say 'Bundled lib.js'
    isl.pipe osl
  finally
    popd!

function compile t, ipath, cb
  odir = Path.dirname opath = get-opath t, ipath
  mkdir '-p', odir # stylus fails if outdir doesn't exist
  switch typeof t.cmd
  | \string =>
    cmd = t.cmd.replace(\$IN, "'#ipath'").replace \$OUT, "'#odir'"
    code, res <- exec cmd
    log code, res if code
    cb (if code then res else void), opath
  | \function =>
    e <- t.cmd ipath, opath
    cb e, opath

function compile-batch tid
  t = tasks[tid]
  # https://github.com/shama/gaze/issues/74
  files = [ f for dir, paths of t.gaze.watched! for f in paths
    when '/' isnt f.slice -1 and (Path.basename f).0 isnt t.mixn ]
  info = "#{files.length} #tid files"
  g.say "compiling #info..."
  for f in files then WFor compile, t, f
  g.ok "...done #info!"

function get-opath t, ipath
  p = ipath.replace("#ROOT/", '').replace t.ixt, t.oxt
  return p unless (xsub = t.xsub?split '->')?
  p.replace xsub.0, xsub.1

function markdown ipath, opath, cb
  e, obj <- Md cat ipath
  obj.to opath unless e?
  cb e

function prepare ipath
  return if /\/task\//.test ipath
  rx = new RegExp "^#ROOT/(app|lib)"
  bundle-app! if rx.test ipath
  opts.on-built!

function prune-empty-dirs
  Assert _.contains pwd!, BUILDOBJ
  code, out <- exec "find . -type d -empty -delete"
  g.err "prune failed: #code #out" if code

function start-watching tid
  log "start watching #tid"
  Assert.equal pwd!, ROOT
  t = tasks[tid]
  t.gaze = Gaze [ "**/*.#{t.ixt}", "!#BUILD/**" ], ->
    act, ipath <- t.gaze.on \all
    return if '/' is ipath.slice -1 # BUG: Gaze might fire when dir added
    WFib ->
      if t.mixn? and (Path.basename ipath).0 is t.mixn then
        try
          compile-batch tid
          bundle-app!
        catch e then g.err e
      else switch act
        | \added, \changed, \renamed
          try opath = WFor compile, t, ipath
          catch e then return g.err e
          g.ok opath
          prepare ipath
        | \deleted
          try W4m Fs, \unlink, opath = get-opath t, ipath
          catch e then throw e unless e.code is \ENOENT # not found i.e. already deleted
          g.ok "Delete #opath"
          prepare ipath
