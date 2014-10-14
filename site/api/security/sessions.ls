Err     = require \../error
M-Users = require \../model/users
Sys     = require \../sys

module.exports =
  after-authenticate: (req, res, next) ->
    return next new Error 'req.user must be present' unless (u = req.user)?
    if Sys.get-is-mode-maintenance! and u.role is \user then return next new Err.Authenticate do
      "User logins are currently disabled for maintenance. Please try again later."
    if d = u.freeze_until and Date.now! < new Date d then return next new Err.Authenticate do
      "Account is temporarily frozen. Please retry in #{M-Users.get-signin-bad-freeze-secs!} seconds"
    next!

  before-authenticate: (req, res, next) ->
    return next new Error 'signout required' if req.session.signin
    next!

  delete: (req, res, next) ->
    return next new Err.AuthenticateRequired unless si = req.session.signin
    return next new Error 'signin mismatch' unless req.id is si.id
    next!
