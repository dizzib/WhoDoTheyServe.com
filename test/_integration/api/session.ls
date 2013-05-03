_ = require \underscore
H = require \./helper
X = require \../spec/session
S = require \../state

module.exports = X.get-spec signin, signout

function signin login, done, is-ok, fields then
  sess = login: login
  err, res, user <- H.post \sessions, _.extend sess, fields
  H.assert res, is-ok
  if H.is-ok res then S.login = user
  done err

function signout done then
  err, res <- H.del "sessions/#{S.login._id}"
  H.ok res
  if H.is-ok res then delete S.login
  done err
