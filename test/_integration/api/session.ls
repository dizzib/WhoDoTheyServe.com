_  = require \lodash
Ex = require \chai .expect
H  = require \./_http
Sp = require \../spec/session
St = require \../state

module.exports = Sp.get-spec signin, signout

function signin handle, is-ok, fields
  res = H.post \sessions, _.extend handle:handle, fields
  Ex(H.is-ok res).to.be.true if is-ok
  Ex(H.is-err res or H.is-redirect res).to.be.true unless is-ok
  # TODO: check redirect goes to /user/signin/error
  if H.is-ok res then St.handle = res.body

function signout
  H.ok res = H.del "sessions/#{St.handle._id}"
  if H.is-ok res then delete St.handle
