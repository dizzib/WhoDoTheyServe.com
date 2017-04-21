Assert   = require \assert
Choki    = require \chokidar
Cron     = require \cron
Emitter  = require \events .EventEmitter
Fs       = require \fs
_        = require \lodash
Md       = require \marked
Path     = require \path
Shell    = require \shelljs/global
WFib     = require \wait.for .launchFiber
W4       = require \wait.for .for
W4m      = require \wait.for .forMethod
Bundle   = require \./bundle
Dir      = require \./constants .dir
Dirname  = require \./constants .dirname
G        = require \./growl

const BIN = "#{Dir.ROOT}/node_modules/.bin"

pruner = new Cron.CronJob cronTime:'*/10 * * * *' onTick:prune-empty-dirs
tasks  =
  livescript:
    cmd : "#BIN/lsc --output $ODIR $IN"
    ixt : \ls
    oxt : \js
    xsub: 'json.js->json'
  markdown:
    cmd : "#BIN/marked --output $OUT --input $IN"
    ixt : \md
    oxt : \html
  pug:
    cmd : "#BIN/pug --obj \"{'basedir':'#{Dir.SITE}/app'}\" --out $ODIR $IN"
    ixt : \pug
    oxt : \html
    mixn: \_
  static:
    cmd : 'cp --target-directory $ODIR $IN'
    ixt : '{css,eot,gif,html,jpg,js,mak,otf,pem,png,svg,ttf,txt,woff,woff2}'
  stylus:
    cmd : "#BIN/stylus -u nib --out $ODIR $IN"
    ixt : \styl
    oxt : \css
    mixn: \_

module.exports = me = (new Emitter!) with
  all: ->
    for tid of tasks then compile-batch tid
    finalise!

  delete: ->
    log "delete #{Dir.BUILD}"
    rm \-rf Dir.BUILD

  start: ->
    G.say 'build started'
    try
      pushd Dir.ROOT
      for tid of tasks then start-watching tid
    finally
      popd!
    pruner.start!

  stop: ->
    pruner.stop!
    for , t of tasks then t.watcher?close!
    G.say 'build stopped'

## helpers

function compile t, ipath, cb
  odir = Path.dirname opath = get-opath t, ipath
  ipath-abs = Path.resolve Dir.ROOT, ipath
  mkdir \-p odir # stylus fails if outdir doesn't exist
  cmd = t.cmd.replace(\$IN "'#ipath-abs'").replace(\$OUT "'#opath'")
  cmd .= replace \$ODIR "'#odir'"
  log cmd
  code, res <- exec cmd
  log code, res if code
  cb (if code then res else void), opath

function compile-batch tid
  t = tasks[tid]
  w = t.watcher.getWatched!
  files = [ f for path, names of w for name in names
    when name.0 isnt t.mixn and test \-f f = Path.resolve Dir.ROOT, path, name ]
  info = "#{files.length} #tid files"
  G.say "compiling #info..."
  for f in files then W4 compile, t, Path.relative Dir.ROOT, f
  G.ok "...done #info!"

function finalise ipath, opath
  const API = <[ /api/ test/_integration/api.ls ]>
  const APP = <[ /app/ test/_integration/app.ls ]>
  function contains then _.some it, -> _.includes ipath, it
  function contains-base then contains ["#it/"]
  if ipath # partial build. site/lib is common to site/api and site/app
    return if contains-base \task
    me.emit \built-api unless contains APP
    switch
    | /\.css$/.test opath => Bundle.css!
    | Bundle.is-lib ipath => Bundle.libs!
    | not (contains-base \test or contains API) => Bundle.app opath
    me.emit \built-app unless contains API
  else # full build
    me.emit \built-api
    Bundle.all!
    me.emit \built-app
  me.emit \built

function get-opath t, ipath
  p = ipath.replace t.ixt, t.oxt if t.ixt?
  return p or ipath unless (xsub = t.xsub?split '->')?
  p.replace xsub.0, xsub.1

function prune-empty-dirs
  unless pwd! is Dir.BUILD then return log 'bypass prune-empty-dirs'
  code, out <- exec "find . -type d -empty -delete"
  G.err "prune failed: #code #out" if code

function start-watching tid
  log "start watching #tid"
  Assert.equal pwd!, Dir.ROOT
  pat = (t = tasks[tid]).pat or "*.#{t.ixt}"
  dirs = "#{Dirname.SITE},#{Dirname.TASK},#{Dirname.TEST}"
  w = t.watcher = Choki.watch [ "{#dirs}/**/#pat" pat ],
    cwd:Dir.ROOT, ignoreInitial:true
  w.on \all _.debounce process, 500ms, leading:true trailing:false

  function process act, ipath
    log act, tid, ipath
    <- WFib
    if (Path.basename ipath).0 is t?mixn
      try
        compile-batch tid
        finalise ipath
      catch e then G.err e
    else switch act
    | \add \change
      try opath = W4 compile, t, ipath
      catch e then return G.err e
      G.ok opath
      finalise ipath, opath
    | \unlink
      Assert.equal pwd!, Dir.BUILD
      try W4m Fs, \unlink, opath = get-opath t, ipath
      catch e then throw e unless e.code is \ENOENT # not found i.e. already deleted
      G.ok "Delete #opath"
      finalise ipath, opath
