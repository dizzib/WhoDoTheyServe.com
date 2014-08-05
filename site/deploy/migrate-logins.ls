_        = require \lodash
M-Logins = require \../api/model/logins
M-Users  = require \../api/model/users

module.exports =
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

      err, login <- M-Logins.findOne login:user.login
      log err, login
      return cb err if err

      if login?
        migrate-user!
      else
        log "create login #{user.login}"
        o = { login:user.login, password:\Pass1! }
        err, login <- (new M-Logins o).save
        return cb err if err
        migrate-user!

      function migrate-user
        user.password  = void
        user.auth_type = \password
        user.login_id  = login._id
        user.name      = login.login

        log "migrating user", user
        err, user <- user.save
        return cb err if err

        log "migrated #{user.login} ok"
        do-next!
