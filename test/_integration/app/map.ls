B  = require \./_browser
C  = require \./_crud
Sp = require \../spec/map
St = require \../state

c = C \map do
  ent-ui     : -> \Map
  fill       : fill
  go-create  : -> B.go \map/new
  go-maintain: go-maintain
  on-create  : on-save
  on-remove  : on-remove
  on-update  : on-save

module.exports = Sp.get-spec c.create, void, c.update, c.remove, list

## helpers

function fill fields
  B.fill Description:fields.description
  B.fill Name:fields.name
  B.click id:\flags.private if fields.flags?private? # toggle
  if ns = fields?nodes
    B.click class:\ms-choice # open multi-select
    for key in ns then B.click St.nodes[key]

function go-maintain key, is-ok, fields
  B.click fields.name, 'ul.maps>li.map>a' include-hidden:true

function list n-expect
  B.click \Maps
  B.assert.count n-expect, sel:\ul.maps>li.map

function on-remove
  B.wait-for \Contributions \legend

function on-save key, fields
  B.wait-for fields.name, '.nav>li .name'
  B.wait-for-visible 'Successfully saved' \.alert-success
