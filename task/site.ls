Chalk  = require \chalk
Cp     = require \child_process
Shell  = require \shelljs/global
Dir    = require \./constants .dir
Cfg    = require \./config
Flags  = require \./flags
G      = require \./growl
Rt     = require \./runtime

module.exports = me =
  recycle:
    dev    : -> recycle-primary Cfg.dev
    staging: -> recycle-primary Cfg.staging
  start: (cwd, cfg, cb) ->
    const RX-ERR = /(expected|error|exception)/i
    v = exec 'node --version' silent:true .output.replace '\n', ''
    desc = get-site-desc cfg
    args = get-start-site-args cfg
    log "start site in node #v: #args"
    return log "unable to start non-existent site at #cwd" unless test \-e cwd
    Cp.spawn \node, (args.split ' '), cwd:cwd, env:env with cfg
      ..stderr.on \data ->
        log-data s = it.toString!
        # data may be fragmented, so only growl relevant packet
        if RX-ERR.test s then G.alert "#desc\n#s" nolog:true
      ..stdout.on \data ->
        log-data it.toString! if Flags.get!site.logging
        cb! if cb and /listening on port/.test it
    function log-data
      log Chalk.gray "#{Chalk.underline desc} #{it.slice 0, -1}"
  stop: (cfg, cb) ->
    Rt.kill-node (get-start-site-args cfg), cb

function get-site-desc cfg
  "#{cfg.NODE_ENV}@#{cfg.PORT}"

function get-start-site-args cfg
  "#{cfg.NODE_ARGS or ''} boot #{get-site-desc cfg}".trim!

function recycle-primary cfg, cb
  <- me.stop cfg.primary
  <- me.start cfg.dirsite, cfg.primary
  cb! if cb?

