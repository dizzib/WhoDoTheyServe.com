C     = require \chai .should!
_     = require \underscore
H     = require \./helper
S     = require \../state
U     = require \../spec/user
Users = require \../../../api/model-users

module.exports = U.get-spec create, read, update, remove, list, verify

function create done, login, is-ok, fields then
  user =
    login   : login
    password: \Pass1!
    email   : "#{login}@domain.com"
  err, res, user <- H.post get-route!, _.extend user, fields
  H.assert res, is-ok
  if H.is-ok res then
    user.login.should.equal login
    S.add-user user
  done err

function read done, login, is-ok, fields then
  throw new Error 'require > 0 fields to assert' unless fields
  err, res, json <- H.get get-route login
  user = JSON.parse json
  H.assert res, is-ok
  for k, v of fields then user[k].should.equal v
  done err

function update done, login, is-ok, fields then
  user =
    _id     : S.users[login]._id
    password: '' # TODO: stop backbone sending this
  err, res, user <- H.put get-route(login), _.extend user, fields
  H.assert res, is-ok
  if H.is-ok res then S.users[user.login] = user
  done err

function remove done, login, is-ok, fields then
  err, res, user <- H.del get-route login
  H.assert res, is-ok
  if H.is-ok res then delete S.users[login]
  done err

function verify done, login, is-ok, fields then
  err, user <- Users.findOne login:login
  return done err if err
  token = fields?token or user.create_token
  err, res, user <- H.get "#{get-route login}/verify/#{token}"
  H.assert res, is-ok
  done err

function list done, n then
  H.list done, get-route!, n

function get-route login then
  return "users/#{S.users[login]._id}" if login
  \users
