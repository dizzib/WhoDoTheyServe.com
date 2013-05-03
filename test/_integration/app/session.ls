C = require \chai .should!
_ = require \underscore
B = require \./browser
H = require \./helper
X = require \../spec/session
S = require \../state

module.exports = X.get-spec signin, signout

function signin login, done, is-ok, fields = {} then
  err <- B.go \#/user-signin
  return done err if err
  fields
    ..login    ||= login
    ..password ||= \Pass1!
  B
    .fill 'Login'   , fields.login
    .fill 'Password', fields.password
  err <- B.pressButton \Login
  B.assert is-ok
  #B.query 'legend'
  done err

function signout done then
  err <- B.go \#/user-signout
  return done err if err
  #B.query 'legend'
  done err

function list done, n then
  err <- B.go \#/users
  B.queryAll '.users li' .length.should.equal n
  done err
