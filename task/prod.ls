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

  login: ->
    try
      W4 exec, "af login --email #uid --passwd #pwd"
    catch e
      log e

  send-env-vars: ->
    exec-then-logout ->
      W4 exec, "af stop #appname" # stop to avoid restarting after each add
      for k, v of cfg.env then W4 exec, "af env-add #appname #k=#v" # normally restarts
      W4 exec, "af start #appname"
      G.ok "sent env-vars to appfog PRODUCTION"

  show-config: ->
    log cfg

  update: ->
    exec-then-logout ->
      # shrinkwrap ensures exact staging dependency tree gets deployed,
      # otherwise there's a small risk of breakage in production
      W4 exec, 'npm shrinkwrap'
      test \-e \npm-shrinkwrap.json

      W4 exec, "af update #appname"
      G.ok "updated site to appfog PRODUCTION"

## helpers

function exec-then-logout fn
  try
    pushd Dir.dist.STAGING
    fn!
  catch e
    log e
  finally
    popd!
    logout!

function logout
  try
    W4 exec, "af logout"
  catch e
    log e
