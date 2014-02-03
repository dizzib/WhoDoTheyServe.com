B = require \./_browser
S = require \../spec/session

module.exports = S.get-spec signin, signout

function signin login, is-ok, fields = {} then
  fields
    ..login    ||= login
    ..password ||= \Pass1!
  B.click \Login, \a
  B.fill Username:fields.login, Password:fields.password
  B.click /Login/, \button
  B.assert.ok is-ok
  B.wait-for \Welcome!, \.main>.show>legend if is-ok

function signout then
  B.pause! # occasionally fails without this pause
  B.click \Logout
  B.assert.ok!
  B.wait-for \Goodbye!, \.main>.show>legend
