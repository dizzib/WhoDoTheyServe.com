_  = require \underscore
E  = require \./entity
SP = require \../spec/edge
ST = require \../state

e = E \edges
module.exports = SP.get-spec create, e.read, update, e.remove, e.list

function create key, is-ok, fields then
  edge =
    a_node_id: ST.nodes[key.0]._id
    b_node_id: ST.nodes[key.1]._id
    a_is     : \lt
    year_from: 2000
  e.create key, is-ok, _.extend edge, fields

function update key, is-ok, fields then
  edge = _id: ST.edges[key]._id
  edge.a_node_id = ST.nodes[fields.key.0]._id if fields.key
  edge.b_node_id = ST.nodes[fields.key.1]._id if fields.key
  e.update key, is-ok, _.extend edge, fields
