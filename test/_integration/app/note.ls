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
  on-remove  : on-remove
  on-update  : on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-create key
  N.go-edge-or-node key
  wait-for-note!
  B.click \New, scope:\el
  B.wait-for /Create/, \button

function go-maintain key
  N.go-edge-or-node key
  wait-for-notes!
  B.click \Edit, scope:\el
  B.wait-for /Update/, \button

function on-remove key
  wait-for-notes!

function on-save key, fields
  wait-for-note!
  B.wait-for fields.text, \span

function wait-for-note
  B.wait-for /Note/, \legend

function wait-for-notes
  B.wait-for /Notes/, \legend
