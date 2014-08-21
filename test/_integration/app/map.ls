B  = require \./_browser
C  = require \./_crud
Sp = require \../spec/map
St = require \../state

c = C \map,
  ent-ui     : -> \Map
  fill       : fill
  go-create  : -> B.go \map/new
  go-maintain: go-maintain
  on-create  : on-save
  on-remove  : -> # override default to do nothing

module.exports = Sp.get-spec c.create, void, c.update, c.remove, c.list

## helpers

function fill fields
  B.fill Description:fields.description
  B.fill Name:fields.name
  B.click class:\ms-choice # open multi-select
  for key in fields?nodes then B.click St.nodes[key]

function go-maintain key, is-ok, fields
  B.click fields.name, '.map a', include-hidden:true

function on-save key, fields
  B.wait-for fields.name, '.nav li'
