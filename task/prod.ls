Assert = require \assert
Shell  = require \shelljs
W4     = require \wait.for .for
Dir    = require \./constants .dir
G      = require \./growl

const AF-APPNAME = \wdts10

try
  cfg = (JSON.parse env.prod).appfog
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
      W4 exec, "af stop #AF-APPNAME"
      for k, v of cfg.env
        W4 exec, "af env-add #AF-APPNAME #k=#v"
      W4 exec, "af start #AF-APPNAME"
      G.ok "sent env-vars to appfog PRODUCTION"

  show-config: ->
    log "AF-APPNAME=#AF-APPNAME"
    log cfg

  update: ->
    exec-then-logout ->
      # shrinkwrap ensures exact staging dependency tree gets deployed,
      # otherwise there's a small risk of breakage in production
      W4 exec, 'npm shrinkwrap'
      test \-e \npm-shrinkwrap.json

      W4 exec, "af update #AF-APPNAME"
      G.ok "updated site to appfog PRODUCTION"

## helpers

function exec-then-logout fn
  try
    pushd Dir.site.STAGING
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
