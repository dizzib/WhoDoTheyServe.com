Chai  = require \chai .should!
_     = require \lodash
W     = require \wait.for
C     = require \./_crud
H     = require \./_http
S     = require \../state
U     = require \../spec/user
Users = require "#{process.cwd!}/site/api/model/users"

c = C \users
module.exports = U.get-spec create, c.read, c.update, c.remove, c.list, verify

function create handle, is-ok, fields then
  user =
    handle  : handle
    password: \Pass1!
    email   : "#{handle}@domain.com"
  H.assert (res = H.post get-route!, _.extend user, fields), is-ok
  if H.is-ok res then
    (user = res.body).handle.should.equal handle
    S.add-user user

function verify handle, is-ok, fields then
  user = W.forMethod Users, \findOne, handle:handle
  token = fields?token or user.create_token
  res = H.get "#{get-route handle}/verify/#{token}"
  H.assert res, is-ok

function get-route handle then
  return "users/#{S.users[handle]._id}" if handle
  \users
