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

function create handle, is-ok, fields = {}
  fields
    ..handle      ||= handle
    ..password    ||= \Pass1!
    ..email       ||= "#{handle}@domain.com"
    ..info        ||= ''
    ..quota_daily ||= \5
  c.create handle, is-ok, fields

## helpers

function go-edit
  B.click \Edit
  B.wait-for /Edit/, \legend>.update

function fill fields then B.fill do
  Username          : fields.handle
  'Password'        : fields.password
  'Confirm Password': fields.password
  Email             : fields.email
  Homepage          : fields.info
  'Daily Quota'     : { value:fields.quota_daily, opts:{ include-hidden:true } }
