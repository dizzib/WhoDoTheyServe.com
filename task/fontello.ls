Sh  = require \shelljs/global
Dir = require \./constants .dir

module.exports =
  open: -> make \fontopen
  save: -> make \fontsave

function make op
  try
    pushd Dir.SITE
    log cmd = "make -f #{Dir.TASK}/fontello.makefile #op"
    code, out <- exec cmd
    log out
    log "exit code #code"
  catch e
    log e
  finally
    popd!
