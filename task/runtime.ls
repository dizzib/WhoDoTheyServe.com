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
    code <- exec cmd = "pkill -f 'node #{args.replace /\*/g '\\*'}'"
    # return codes:
    #   0 One or more processes matched the criteria.
    #   1 No processes matched.
    #   2 Syntax error in the command line.
    #   3 Fatal error: out of memory etc.
    throw new Error "#pg returned #code" if code > 1
    cb!
