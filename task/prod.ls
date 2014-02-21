Assert = require \assert
Shell  = require \shelljs/global
WFib   = require \wait.for .launchFiber
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod

for k in <[ appfog ]> then
  Assert (cfg = env.prod), "config #k not found in env"

module.exports =
  login: ->
    WFor exec, "af login #{cfg.appfog.account.uid}"

  push: ->
    code = WFor exec, 'npm shrinkwrap' # prevent node 0.8/0.10 bcrypt version mismatch
    log code
    #code = WFor exec, 'af update whodotheyserve'

