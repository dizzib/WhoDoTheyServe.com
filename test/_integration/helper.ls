R = require \readline
_ = require \underscore
W = require \wait.for

module.exports =
  # mocha test wrapper
  run: (fn) ->
    (done) ->
      <- W.launchFiber
      try
        fn!
        done!
      catch e
        #<- keep-marionette-session-alive e
        done e

      function keep-marionette-session-alive e, cb
        log e
        rl = R.createInterface input:process.stdin, output:process.stdout
        <- rl.question "press enter to continue"
        cb!