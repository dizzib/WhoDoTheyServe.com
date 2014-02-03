_  = require \underscore
H  = require \./_http
SP = require \../spec/session
ST = require \../state

module.exports = SP.get-spec signin, signout

function signin login, is-ok, fields then
  sess = login: login
  H.assert (res = H.post \sessions, _.extend sess, fields), is-ok
  if H.is-ok res then ST.login = res.body

function signout then
  H.ok res = H.del "sessions/#{ST.login._id}"
  if H.is-ok res then delete ST.login
