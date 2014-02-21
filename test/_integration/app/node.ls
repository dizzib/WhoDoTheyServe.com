B  = require \./_browser
C  = require \./_crud
SP = require \../spec/node
ST = require \../state

c = C \node,
  ent-ui   : -> \Actor
  fill     : -> B.fill Name:it.name
  go-entity: go-entity
  on-create: on-save
  on-update: on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function go-entity key then
  B.click name = ST.nodes[key], \a
  B.wait-for name, \h2>.name

function on-save key, fields then
  (ST.nodes ?= {})[key] = fields.name
  B.wait-for fields.name, \h2>.name
  B.click \Actors
  B.wait-for fields.name, \a
