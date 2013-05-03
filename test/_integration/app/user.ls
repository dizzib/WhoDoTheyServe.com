C = require \chai .should!
_ = require \underscore
B = require \./browser
H = require \./helper
S = require \../state
U = require \../spec/user

module.exports = U.get-spec create, read, update, remove, list, verify

function create done, login, is-ok, fields = {} then
  err <- B.go \#/user-signup
  return done err if err
  fields
    ..login     ||= login
    ..password  ||= \Pass1!
    ..email     ||= "#{login}@domain.com"
    ..info      ||= ''
  H.log B.cookies
  H.log 'create', login, fields
  B
    .fill 'Username'        , fields.login
    .fill 'Password'        , fields.password
    .fill 'Confirm Password', fields.password
    .fill 'Email'           , fields.email
    .fill 'Homepage'        , fields.info
  err <- B.pressButton \Create
  B.assert is-ok
  if B.is-ok! then
    S.add-user fields
  done err

function read done, login, is-ok, fields then
  H.log login, S.users #[login]
  err <- B.go \#/user-info
  #user = JSON.parse json
  #H.assert res, is-ok
  #for k, v of fields then user[k].should.equal v
  done err

function update done, login, is-ok, fields then
  err <- B.go \#/user-edit
  #user =
  #  _id     : H.users[login]._id
  #  password: '' # TODO: stop backbone sending this
  #err, res, user <- H.put get-route(login), _.extend user, fields
  #H.assert res, is-ok
  #if H.is-ok res then H.users[user.login] = user
  done err

function remove done, login, is-ok, fields then
  err <- B.go \#/user-edit
  #H.assert res, is-ok
  #if H.is-ok res then delete H.users[login]
  done err

function verify done, login, is-ok, fields then
  err <- B.go "#/api/users/#{login}/verify"
  #H.assert res, is-ok
  #if H.is-ok res then delete H.users[login]
  done err

function list done, n then
  err <- B.go \#/users
  B.queryAll('.users li').length.should.equal n
  done err
