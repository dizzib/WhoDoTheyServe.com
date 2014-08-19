_    = require \lodash
W4   = require \wait.for .for
H    = require \../helper
Http = require \./_http

module.exports = _.extend do
  get-spec leg1
  get-spec leg2

function get-spec op
  "#{op.name}":
    ok : get-spec-test op, true
    bad: get-spec-test op, false

function get-spec-test op, is-ok
  info: "openauth #{op.name} #{if is-ok then '' else 'bad '}"
  fn  : H.run -> op is-ok

function leg1 is-ok
  res = W4 Http.get, \auth/mock
  Http.is-redirect res .should.equal is-ok

function leg2 is-ok
  res = W4 Http.get, \auth/mock/callback
  Http.is-redirect res .should.equal is-ok
