Assert = require \assert
Shell  = require \shelljs/global
W4     = require \wait.for .for
Dir    = require \../constants .dir

module.exports =
  delete-modules: ->
    dir = "#{Dir.ROOT}/node_modules"
    log "delete #dir"
    rm \-rf dir

  update-modules: ->
    pushd Dir.ROOT
    try
      Assert.equal pwd!, Dir.ROOT
      W4 exec, 'npm -v'
      W4 exec, 'npm prune'
      W4 exec, 'npm update'
    finally
      popd!
