B = require \./_browser
C = require \./_crud
S = require \../spec/user

c = C \user,
  ent-ui   : -> \Contributor
  fill     : fill
  go-create: -> B.go \user/signup
  go-edit  : go-edit
  go-list  : -> B.go \users
  on-create: -> B.wait-for /Goodbye|Welcome/, \.main>.show>legend
  on-update: -> B.wait-for it, '.main h2'

module.exports = S.get-spec create, void, c.update, c.remove, c.list

function create login, is-ok, fields = {}
  fields
    ..login       ||= login
    ..password    ||= \Pass1!
    ..email       ||= "#{login}@domain.com"
    ..info        ||= ''
    ..quota_daily ||= \5
  c.create login, is-ok, fields

## helpers

function go-edit
  B.click \Edit
  B.wait-for /Edit Account/, \legend>.update

function fill fields then B.fill do
  Username          : fields.login
  'Password'        : fields.password
  'Confirm Password': fields.password
  Email             : fields.email
  Homepage          : fields.info
  'Daily Quota'     : fields.quota_daily
