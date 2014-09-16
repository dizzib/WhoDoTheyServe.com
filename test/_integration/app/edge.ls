_  = require \lodash
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
  is-new = _.isEmpty o
  select-node 'Actor A', ST.nodes[key.0] if is-new
  select-node 'Actor B', ST.nodes[key.1] if is-new
  B.fill How:key, When:o.when
  B.fill /subordinate/, (o.a_is is \lt or not o.a_is?)
  B.fill /peer/, o.a_is is \eq

function select-node label, text
  B.wait-for label
  B.wait-for sel:"input[type='text']" scope:\el.parent
  B.send-keys "#{text}\n"
