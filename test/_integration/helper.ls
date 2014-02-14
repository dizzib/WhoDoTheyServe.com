CP = require \child_process
_  = require \underscore
W  = require \wait.for

module.exports =

  # mocha test wrapper
  run: (fn) ->
    (done) ->
      W.launchFiber ->
        try
          fn!
          done!
        catch e
          done e
