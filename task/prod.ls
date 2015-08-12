Shl = require \shelljs
W4  = require \wait.for .for
Dir = require \./constants .dir
G   = require \./growl

try cfg = (JSON.parse env.prod).site
catch

module.exports =
  enabled : -> cfg?
  show-cfg: -> log cfg

  af:
    login: ->
      <- try-exec
      W4 exec, "af login --email #{cfg.af.account.uid} --passwd #{cfg.af.account.pwd}"
    logout: ->
      <- try-exec
      W4 exec, "af logout"
    send-env-vars: ->
      <- try-exec
      appname = cfg.af.appname
      env = cfg.env <<< cfg.af.env
      W4 exec, "af stop #appname" # stop to avoid restarting after each add
      for k, v of env then W4 exec, "af env-add #appname #k=#v" # normally restarts
      W4 exec, "af start #appname"
      G.ok "sent env-vars to appfog PRODUCTION"
    update: ->
      <- try-exec
      appname = cfg.af.appname
      # shrinkwrap ensures exact staging dependency tree gets deployed,
      # otherwise there's a small risk of breakage in production
      W4 exec, 'npm shrinkwrap'
      return log error! if error!
      test \-e \npm-shrinkwrap.json
      W4 exec, "af update #appname"
      return log error! if error!
      G.ok "updated site to appfog PRODUCTION"

  rhc:
    deployments:
      activate: (rl) ->
        function question text, cb
          ans <- rl.question text
          cb null, ans
        id = W4 question, "Enter deployment id:"
        return log 'must be 8 chars' unless id.length is 8
        rhc "deployment show #id"
        sure = W4 question, "Are you sure (y/n)?"
        rhc "deployment activate #id" if sure is \y
      list: -> rhc 'deployment list'
    env:
      list: -> rhc 'env list'
      send: ->
        <- try-exec
        env = cfg.env <<< cfg.rhc.env
        vars = ["#k=#v" for k, v of env].join ' '
        rhc "env set #vars"
        return log error! if error!
        G.ok "sent env-vars to openshift PRODUCTION"

function rhc cmd
  appname = cfg.rhc.appname
  W4 exec, "rhc #cmd -a #appname"

function try-exec fn
  try
    pushd Dir.dist.STAGING
    fn!
  catch e
    log e
  finally
    popd!
