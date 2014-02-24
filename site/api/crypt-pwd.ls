Bcrypt = require \bcrypt

# http://devsmash.com/blog/password-authentication-with-mongoose-and-bcrypt
exports
  ..hash = (user, next) ->
    const SALT_WORK_FACTOR = 10
    return next new Error 'cannot hash a hash!' if exports.is-hashed user.password
    # salt prevents rainbow table attack
    err, salt <- Bcrypt.genSalt SALT_WORK_FACTOR
    return next err if err
    err, hash <- Bcrypt.hash user.password, salt
    return next err if err
    user.password = hash
    next!
  ..check = (candidate, hash, cb) ->
    err, is-match <- Bcrypt.compare candidate, hash
    cb err, is-match
  ..is-hashed = (pwd) ->
    # http://stackoverflow.com/questions/5881169/storing-a-hashed-password-bcrypt-in-a-database-type-length-of-column
    pwd.length is 60
