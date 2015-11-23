Shl = require \shelljs
W4  = require \wait.for .for
Dir = require \./constants .dir
G   = require \./growl

try cfg = (JSON.parse env.prod).site
catch

module.exports =
  enabled : -> cfg?
  show-cfg: -> log cfg

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
