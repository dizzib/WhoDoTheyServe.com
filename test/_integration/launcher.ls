CP = require \child_process
M  = require \mongoose
N  = require \net
DB = require \../../api/db
H  = require \./helper

module.exports =

  reset: (cb) ->
    log \RESET
    <- kill-site
    <- drop-db
    site = spawn-site!
    site.stderr.on \data, -> H.log "#{it}"
    site.stdout.on \data, ->
      #H.log "#{it}"
      cb! if /listening on port/.test it

  respawn: (cb) ->
    log \RESPAWN
    <- kill-site
    site = spawn-site detached:true stdio:\inherit
    cb!
    #site.unref! # allow parent process to exit independently of child process

## private fns

function drop-db cb then
  M.disconnect!
  DB.connect!
  err <- M.connection.db.executeDbCommand dropDatabase:1
  throw new Error "dropDatabase failed: #{err}" if err
  cb!

function kill-site cb then
  H.kill 'node boot.js test', cb

function spawn-site opts then
  CP.spawn \node, <[ boot.js test ]>, opts
