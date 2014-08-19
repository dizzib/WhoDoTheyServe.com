_    = require \lodash
W4   = require \wait.for .for
H    = require \../helper
Http = require \./_http

module.exports = me = _.extend do
  oa1 : get-spec-tests \oa1
  oa2 : get-spec-tests \oa2
  fail: get-spec-tests \fail

function get-spec-tests name
  const PATH = "auth/mock/#name"

  function get-spec op
    "#{op.name}":
      ok : get-spec-test op, true
      bad: get-spec-test op, false

  function get-spec-test op, is-ok
    info: "openauth #name #{op.name} #{if is-ok then '' else 'bad '}"
    fn  : H.run -> op is-ok

  function leg1 is-ok
    res = W4 Http.get, PATH
    Http.assert-redirect res, "/api/#PATH/callback" if is-ok
    Http.assert-redirect res, "/#/user/signin/error" unless is-ok

  function leg2 is-ok
    res = W4 Http.get, "#PATH/callback"
    Http.assert-redirect res, "/#/user" if is-ok
    Http.assert-redirect res, "/#/user/signin/error" unless is-ok

  _.extend do
    get-spec leg1
    get-spec leg2
