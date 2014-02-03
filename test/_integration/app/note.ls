C  = require \./crud
F  = require \./firedrive
H  = require \./helper
SP = require \../spec/note

c = C \note,
  fill       : -> F.fill /Enter your note/, it.text
  go-create  : go-create
  go-list    : H.go-entity
  go-maintain: go-maintain
  on-create  : on-save
  on-update  : on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-create key then
  H.go-entity key
  F.wait-for /Note/, \legend
  F.click \New, scope:\el

function go-maintain key then
  H.go-entity key
  F.wait-for /Notes/, \legend
  F.click \Edit, scope:\el

function on-save key, fields then
  F.wait-for /Note/, \legend
  F.wait-for fields.text, \span
