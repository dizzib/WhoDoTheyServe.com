Bcrypt = require \bcrypt

# http://devsmash.com/blog/password-authentication-with-mongoose-and-bcrypt
module.exports = me =
  hash: (login, next) ->
    const SALT_WORK_FACTOR = 10
    return next new Error 'cannot hash a hash!' if me.is-hashed login.password
    # salt prevents rainbow table attack
    err, salt <- Bcrypt.genSalt SALT_WORK_FACTOR
    return next err if err
    err, hash <- Bcrypt.hash login.password, salt
    return next err if err
    login.password = hash
    next!
  check: (candidate, hash, cb) ->
    err, is-match <- Bcrypt.compare candidate, hash
    cb err, is-match
  is-hashed: (pwd) ->
    # http://stackoverflow.com/questions/5881169/storing-a-hashed-password-bcrypt-in-a-database-type-length-of-column
    pwd.length is 60
