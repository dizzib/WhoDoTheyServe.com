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
  on-update  : on-save
  on-remove  : -> delete ST.evidences[it]

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-create key then
  N.go-edge-or-node key
  B.wait-for /Evidence/, \legend
  B.click \New, scope:\el

function go-maintain key then
  N.go-edge-or-node key
  B.wait-for ST.evidences[key], \a
  B.click \Edit, scope:\el.parent

function on-save key, fields then
  B.wait-for /Evidence/, \legend
  B.wait-for fields.url, \a
  (ST.evidences ?= {})[key] = fields.url
