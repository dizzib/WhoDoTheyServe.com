C  = require \./crud
F  = require \./firedrive
H  = require \./helper
SP = require \../spec/evidence
ST = require \../state

c = C \evidence,
  coll-ui    : -> \Evidence
  fill       : -> F.fill Url:it.url
  go-create  : go-create
  go-list    : H.go-entity
  go-maintain: go-maintain
  on-create  : on-save
  on-update  : on-save
  on-remove  : -> delete ST.evidences[it]

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-create key then
  H.go-entity key
  F.wait-for /Evidence/, \legend
  F.click \New, scope:\el

function go-maintain key then
  H.go-entity key
  F.wait-for ST.evidences[key], \a
  F.click \Edit, scope:\el.parent

function on-save key, fields then
  F.wait-for /Evidence/, \legend
  F.wait-for fields.url, \a
  (ST.evidences ?= {})[key] = fields.url
