_  = require \lodash
C  = require \./_crud
H  = require \./_http
SP = require \../spec/map
ST = require \../state

c = C \maps
module.exports = SP.get-spec create, c.read, c.update, c.remove, c.list

function create key, is-ok, fields
  map =
    name    : fields.name
    nodes   : [ { _id:ST.nodes[k]._id, x:100, y:200 } for k in fields.nodes]
    'size-x': 500
    'size-y': 500
  c.create key, is-ok, map
