B = require \bcryptjs

# http://devsmash.com/blog/password-authentication-with-mongoose-and-bcrypt
module.exports = me =
  hash: (login, next) ->
    return next new Error 'cannot hash a hash!' if me.is-hashed login.password
    # speed up test runs
    rounds = if /^test*/.test process.env.NODE_ENV then 1 else 10
    # salt prevents rainbow table attack
    err, salt <- B.genSalt rounds
    return next err if err
    err, hash <- B.hash login.password, salt
    return next err if err
    login.password = hash
    next!
  check: (candidate, hash, cb) ->
    err, is-match <- B.compare candidate, hash
    cb err, is-match
  is-hashed: (pwd) ->
    # http://stackoverflow.com/questions/5881169/storing-a-hashed-password-bcrypt-in-a-database-type-length-of-column
    pwd.length is 60
