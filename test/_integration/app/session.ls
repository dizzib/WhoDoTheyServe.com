F = require \./firedrive
H = require \./helper
S = require \../spec/session

module.exports = S.get-spec signin, signout

function signin login, is-ok, fields = {} then
  fields
    ..login    ||= login
    ..password ||= \Pass1!
  F.click \Login, \a
  F.fill Username:fields.login, Password:fields.password
  F.click /Login/, \button
  H.assert-ok is-ok
  F.wait-for \Welcome!, \.main>.show>legend if is-ok

function signout then
  F.pause! # occasionally fails without this pause
  F.click \Logout
  H.assert-ok!
  F.wait-for \Goodbye!, \.main>.show>legend
