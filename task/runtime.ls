Sh  = require \shelljs/global
Dir = require \./constants .dir
Cfg = require \./config

Cfg.dev             <<< dirsite:Dir.build.SITE
Cfg.dev.primary     <<< JSON.parse env.dev if env.dev
Cfg.staging         <<< dirsite:Dir.dist.STAGING
Cfg.staging.primary <<< JSON.parse env.staging if env.staging

module.exports =
  kill-node: (args, cb) ->
    # pkill --echo not supported by Travis
    # can't use WaitFor as we need the return code
    pg = "pgrep -d ' ' -f 'node #{args.replace /\*/g '\\*'}'"
    code, pids <- exec pg, silent:true
    # pgrep return codes:
    #   0 One or more processes matched the criteria.
    #   1 No processes matched.
    #   2 Syntax error in the command line.
    #   3 Fatal error: out of memory etc.
    return cb! if code is 1
    throw new Error "#pg returned #code" if code > 1

    pids .= replace '\n' ''
    log "kill #pids node #args"
    code <- exec k = "kill #pids"
    throw new Error "#k returned #code" if code > 0
    cb!
