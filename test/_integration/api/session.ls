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
  St.handle = res.body if H.is-ok res

function signout is-ok
  res = H.del "sessions/#{St.handle._id}"
  H.assert res, is-ok
  delete St.handle if H.is-ok res
