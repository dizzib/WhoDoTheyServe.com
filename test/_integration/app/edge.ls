B  = require \./_browser
C  = require \./_crud
N  = require \./_nav
SP = require \../spec/edge
ST = require \../state

c = C \edge,
  ent-ui   : -> \Connection
  fill     : fill
  go-entity: N.go-edge-or-node

module.exports = SP.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function fill o = {}, key
  select-node 'Actor A', ST.nodes[key.0]
  select-node 'Actor B', ST.nodes[key.1]
  B.fill How:key, 'Year From':(o.year_from || 2000), 'Year To':o.year_to
  B.fill /subordinate/, (o.a_is is \lt or not o.a_is?)
  B.fill /peer/, o.a_is is \eq

function select-node label, text
  B.wait-for label
  B.wait-for sel:"input[type='text']" scope:\el.parent
  B.send-keys "#{text}\n"
