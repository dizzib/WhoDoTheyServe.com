C = require \./crud
F = require \./firedrive
H = require \./helper
S = require \../spec/user

c = C \user,
  ent-ui   : -> \Contributor
  fill     : fill
  go-create: -> F.go \user/signup
  go-edit  : go-edit
  on-create: -> F.wait-for /Goodbye|Welcome/, \.main>.show>legend

module.exports = S.get-spec create, void, c.update, c.remove, c.list

function create login, is-ok, fields = {} then
  fields
    ..login       ||= login
    ..password    ||= \Pass1!
    ..email       ||= "#{login}@domain.com"
    ..info        ||= ''
    ..quota_daily ||= \5
  c.create login, is-ok, fields

## helpers

function go-edit then
  F.click \Edit
  F.wait-for /Edit Account/, \legend>.update

function fill fields then F.fill do
  Username          : fields.login
  'Password'        : fields.password
  'Confirm Password': fields.password
  Email             : fields.email
  Homepage          : fields.info
  'Daily Quota'     : fields.quota_daily
