C  = require \./crud
F  = require \./firedrive
H  = require \./helper
SP = require \../spec/edge
ST = require \../state

c = C \edge,
  ent-ui   : -> \Connection
  fill     : fill
  go-entity: H.go-entity

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function fill o = {}, key then
  select-node 'Actor A', ST.nodes[key.0]
  select-node 'Actor B', ST.nodes[key.1]
  F.fill How:key, 'Year From':(o.year_from || 2000), 'Year To':o.year_to
  F.fill /subordinate/, (o.a_is is \lt or not o.a_is?)
  F.fill /peer/, o.a_is is \eq

function select-node label, text then
  F.wait-for label
  F.wait-for sel:"input[type='text']" scope:\el.parent
  F.send-keys "#{text}\n"
