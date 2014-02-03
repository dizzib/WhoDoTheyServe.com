CP = require \child_process
_  = require \underscore
W  = require \wait.for

module.exports =

  kill: (cmd, cb) ->
    err <- CP.exec "pkill -f '#{cmd}'"
    # err.code:
    # 0 One or more processes matched the criteria. 
    # 1 No processes matched. 
    # 2 Syntax error in the command line. 
    # 3 Fatal error: out of memory etc. 
    throw new Error "pkill #{cmd} returned #{err?code}" if err?code > 1
    cb err

  # mocha test wrapper
  run: (fn) ->
    (done) ->
      W.launchFiber ->
        fn!
        done!
