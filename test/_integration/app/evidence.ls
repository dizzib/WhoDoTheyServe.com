B  = require \./_browser
C  = require \./_crud
N  = require \./_nav
SP = require \../spec/evidence
ST = require \../state

c = C \evidence,
  coll-ui    : -> \Evidence
  fill       : -> B.fill Url:it.url
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
  wait-for-list!
  B.click \New, scope:\el
  B.wait-for /Create/, \button

function go-maintain key
  N.go-edge-or-node key
  wait-for-list!
  B.wait-for ST.evidences[key], \a
  B.click \Edit, scope:\el.parent
  B.wait-for /Update/, \button

function on-remove key
  wait-for-list!
  delete ST.evidences[key]

function on-save key, fields
  wait-for-list!
  B.wait-for fields.url, \a
  (ST.evidences ?= {})[key] = fields.url

function wait-for-list
  B.wait-for-visible /Evidence/, \legend
