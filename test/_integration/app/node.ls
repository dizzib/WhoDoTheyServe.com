B  = require \./_browser
C  = require \./_crud
SP = require \../spec/node
ST = require \../state

c = C \node,
  ent-ui   : -> \Actor
  fill     : fill
  go-entity: go-entity
  on-create: on-save
  on-update: on-save

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function fill o, key
  B.fill Name:o.name if o.name?
  B.fill When:o.when if o.when?

function go-entity key
  B.click name = ST.nodes[key], \li>a>.name
  B.wait-for name, \h2>.name

function on-save key, fields
  ST.{}nodes[key] = fields.name if fields.name?
  B.wait-for name = ST.nodes[key], \h2>.name
  B.click \Actors
  B.wait-for name, \a>.name
