_  = require \lodash
Ex = require \chai .expect
H  = require \./_http
S  = require \../spec/session
ST = require \../state

module.exports = S.get-spec signin, read, signout

function signin key, is-ok, fields # signin
  res = H.post \sessions, _.extend handle:key, fields
  Ex(H.is-ok res).to.be.true if is-ok
  Ex(H.is-err res or H.is-redirect res).to.be.true unless is-ok
  # TODO: check redirect goes to /user/signin/error
  return unless is-ok
  ST.session = res.body

function read key, is-ok, fields
  H.assert (res = H.get \sessions), is-ok
  return unless is-ok
  ST.session = o = res.object
  if fields then for k, v of fields then Ex(o[k]).to.equal v else Ex(o).to.not.exist

function signout key, is-ok # signout
  res = H.del "sessions/#{ST.session._id}"
  H.assert res, is-ok
  delete ST.session if H.is-ok res
