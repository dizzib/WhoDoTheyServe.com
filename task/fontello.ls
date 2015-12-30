Sh  = require \shelljs/global
Dir = require \./constants .dir

module.exports =
  open: -> make \fontopen
  save: -> make \fontsave

function make cmd
  try
    pushd Dir.SITE
    log "make -f #{Dir.TASK}/fontello.makefile #cmd"
    exec "make -f #{Dir.TASK}/fontello.makefile #cmd"
  catch e
    log e
  finally
    popd!
