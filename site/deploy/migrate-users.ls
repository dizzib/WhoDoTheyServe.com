_        = require \lodash
M-Logins = require \../api/model/logins
M-Users  = require \../api/model/users

module.exports =
  drop-indexes: (cb) ->
    err, o <- M-Users.collection.dropIndex \login_1
    log err, o
    cb err if err
    err, o <- M-Users.collection.dropIndex \email_1
    log err, o
    cb err

  migrate: (cb) ->
    err, users <- M-Users.find
    return cb err if err

    log "migrating #{users.length} users"
    do-next!

    function do-next
      user = users.shift!
      return cb! unless user
     #return do-next! if user.login_id # already done ?
      return do-next! unless user.login

      err, login <- M-Logins.findOne handle:user.login
     #log err, login
      return cb err if err
      return migrate-user user, login if login?

      o = { handle:user.login, password:\Pass1! }
      log "create login", o
      err, login <- (new M-Logins o).save
      return cb err if err
      migrate-user user, login

    function migrate-user user, login
      user.auth_type = \password
      user.login     = void # comment out to enable repeat runs
      user.login_id  = login._id
      user.name      = login.handle
      user.password  = void

      log "migrating user", user
      err, user <- user.save
      return cb err if err

      log "migrated #{login.handle} ok"
      do-next!
