CryptPwd = require \../crypt-pwd
Err      = require \../error
M-Logins = require \../model/logins
M-Users  = require \../model/users

# standard password authentication

const MSG-FAIL = "Login failed! Please ensure your username and password are correct."

module.exports =
  authenticate: (req, res, next) ->
    function fail user
      return next new Err.Api MSG-FAIL unless user and M-Users.get-signin-bad-freeze-secs! > 0
      err <- M-Users.freeze user
      return next err if err
      next new Err.Api MSG-FAIL

    err, login <- M-Logins.findOne handle:(b = req.body).handle
    return next err if err
    return fail! unless login
    err, u <- M-Users.findOne login_id:login._id
    return next err if err
    return fail! unless u
    return new Err.Authenticate 'auth_type must be password' unless M-Users.check-is-authtype-password u
    err, is-match <- CryptPwd.check b.password, login.password
    return next err if err
    return fail u unless is-match
    req.user = u
    M-Users.unfreeze u, next
