Sh  = require \shelljs/global
Dir = require \./constants .dir

module.exports =
  open: -> make \fontopen
  save: -> make \fontsave

function make op
  try
    pushd Dir.TASK
    log cmd = "make --file=./fontello.mak #op"
    code, out <- exec cmd
    log out
    log "exit code #code"
  catch e
    log e
  finally
    popd!
