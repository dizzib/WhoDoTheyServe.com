B  = require \./_browser
C  = require \./_crud
N  = require \./_nav
SP = require \../spec/note

c = C \note,
  fill       : -> B.fill /Enter your note/, it.text
  go-create  : go-create
  go-list    : N.go-edge-or-node
  go-maintain: go-maintain
  on-create  : on-save
  on-update  : on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-create key then
  N.go-edge-or-node key
  B.wait-for /Note/, \legend
  B.click \New, scope:\el

function go-maintain key then
  N.go-edge-or-node key
  B.wait-for /Notes/, \legend
  B.click \Edit, scope:\el

function on-save key, fields then
  B.wait-for /Note/, \legend
  B.wait-for fields.text, \span
