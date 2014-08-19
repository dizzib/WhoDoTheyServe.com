Chai  = require \chai .should!
_     = require \lodash
W     = require \wait.for
C     = require \./_crud
H     = require \./_http
S     = require \../state
U     = require \../spec/user
Users = require "#{process.cwd!}/site/api/model/users"

c = C \users
module.exports = U.get-spec create, read, c.update, c.remove, c.list

function create handle, is-ok, fields then
  user =
    handle  : handle
    password: \Pass1!
    email   : "#{handle}@domain.com"
  H.assert (res = H.post get-route!, _.extend user, fields), is-ok
  if H.is-ok res then
    (user = res.body).handle.should.equal handle
    S.add-user user

function read key, is-ok, fields
  throw new Error 'need > 0 fields to assert' unless fields
  H.assert (res = H.get get-route key), is-ok
  #unless S.users[handle]
  for k, v of fields then res.object[k].should.deep.equal v
  res

function get-route handle then
  return "users/#{S.users[handle]._id}" if handle
  \users
