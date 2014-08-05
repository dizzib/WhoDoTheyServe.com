_  = require \lodash
H  = require \./_http
SP = require \../spec/session
ST = require \../state

module.exports = SP.get-spec signin, signout

function signin handle, is-ok, fields then
  sess = handle: handle
  H.assert (res = H.post \sessions, _.extend sess, fields), is-ok
  if H.is-ok res then ST.handle = res.body

function signout then
  H.ok res = H.del "sessions/#{ST.handle._id}"
  if H.is-ok res then delete ST.handle
