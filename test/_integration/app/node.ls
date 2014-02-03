C  = require \./crud
F  = require \./firedrive
H  = require \./helper
SP = require \../spec/node
ST = require \../state

c = C \node,
  ent-ui   : -> \Actor
  fill     : -> F.fill Name:name = it.name
  go-entity: go-entity
  on-create: on-save
  on-update: on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-entity key then
  F.click name = ST.nodes[key], \a
  F.wait-for name, \h2>.name

function on-save key, fields then
  (ST.nodes ?= {})[key] = fields.name
  F.wait-for fields.name, \h2>.name
  F.click \Actors
  F.wait-for fields.name, \a
