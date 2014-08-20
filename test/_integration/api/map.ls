_  = require \lodash
C  = require \./_crud
H  = require \./_http
SP = require \../spec/map
ST = require \../state

c = C \maps
module.exports = SP.get-spec create, read, c.update, c.remove, c.list

function create key, is-ok, fields
  c.create key, is-ok, get-payload fields

function read key, is-ok, fields
  res = c.read key, is-ok, get-payload fields
  ST.maps[key] = res.object

function get-payload fields
  name : fields.name
  nodes: [ { _id:ST.nodes[k]._id, x:100, y:200 } for k in fields.nodes]
  size : { x:500, y:500 }
