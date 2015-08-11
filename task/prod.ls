Assert = require \assert
Shell  = require \shelljs
W4     = require \wait.for .for
Dir    = require \./constants .dir
G      = require \./growl

try
  cfg = (JSON.parse env.prod).appfog
  Assert appname = cfg.appname
  Assert uid = cfg.account.uid
  Assert pwd = cfg.account.pwd
catch

module.exports =
  is-cfg: -> cfg?
  show-config: -> log cfg

  af:
    login: ->
      <- try-exec
      W4 exec, "af login --email #uid --passwd #pwd"
    logout: ->
      <- try-exec
      W4 exec, "af logout"
    send-env-vars: ->
      <- try-exec
      W4 exec, "af stop #appname" # stop to avoid restarting after each add
      for k, v of cfg.env then W4 exec, "af env-add #appname #k=#v" # normally restarts
      W4 exec, "af start #appname"
      G.ok "sent env-vars to appfog PRODUCTION"
    update: ->
      <- try-exec
      # shrinkwrap ensures exact staging dependency tree gets deployed,
      # otherwise there's a small risk of breakage in production
      W4 exec, 'npm shrinkwrap'
      return log error! if error!
      test \-e \npm-shrinkwrap.json
      W4 exec, "af update #appname"
      return log error! if error!
      G.ok "updated site to appfog PRODUCTION"

function try-exec fn
  try
    pushd Dir.dist.STAGING
    fn!
  catch e
    log e
  finally
    popd!
