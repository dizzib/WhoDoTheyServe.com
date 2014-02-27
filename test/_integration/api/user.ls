Chai  = require \chai .should!
_     = require \underscore
W     = require \wait.for
C     = require \./_crud
H     = require \./_http
S     = require \../state
U     = require \../spec/user
Users = require "#{process.cwd!}/site/api/model/users"

c = C \users
module.exports = U.get-spec create, c.read, c.update, c.remove, c.list, verify

function create login, is-ok, fields then
  user =
    login   : login
    password: \Pass1!
    email   : "#{login}@domain.com"
  H.assert (res = H.post get-route!, _.extend user, fields), is-ok
  if H.is-ok res then
    (user = res.body).login.should.equal login
    S.add-user user

function verify login, is-ok, fields then
  user = W.forMethod Users, \findOne, login:login
  token = fields?token or user.create_token
  res = H.get "#{get-route login}/verify/#{token}"
  H.assert res, is-ok

function get-route login then
  return "users/#{S.users[login]._id}" if login
  \users
