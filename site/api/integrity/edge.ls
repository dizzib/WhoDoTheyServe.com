_           = require \lodash
Err         = require \../error
M-Edges     = require \../model/edges
M-Maps      = require \../model/maps
M-Evidences = require \../model/evidences
When        = require \../../lib/when

module.exports =
  create:
    node: (req, res, next) ->
      function check-node-has-evidence id, cb
        err, evi <- M-Evidences.findOne entity_id:id
        return cb err if err
        return cb new Err.Api 'Cannot create an edge to a node lacking evidence' unless evi
        cb!
      err <- check-node-has-evidence req.body.a_node_id
      return next err if err
      check-node-has-evidence req.body.b_node_id, next
    when: (req, res, next) ->
      # always check: treat null-when as full range
      check-chronology req.body, next
  update:
    node: (req, res, next) ->
      return next! unless (b = req.body).a_node_id or b.b_node_id
      return next! if req.session.signin.role is \admin
      err, edge <- M-Edges.findById req.id
      return next err if err
      const MSG = 'Only admin can update'
      return next new Err.Api "#MSG a_node_id" if b.a_node_id and edge.a_node_id isnt b.a_node_id
      return next new Err.Api "#MSG b_node_id" if b.b_node_id and edge.b_node_id isnt b.b_node_id
      next!
    when: (req, res, next) ->
      # always check: treat null-when as full range
      err, edge <- M-Edges.findById req.id
      return next err if err
      # node(s) may have changed so merge whole req.body into existing edge
      check-chronology (edge <<< req.body), next
  delete: (req, res, next) ->
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new Err.Api 'Cannot delete an evidenced edge' if obj
    err, maps-having-edge <- get-maps-having-edge req.id
    return next err if err
    if maps-having-edge.length > 0
      map-names = (_.map maps-having-edge, -> it.name).join ', '
      msg = "Cannot delete edge because it appears on the following maps: #map-names"
      return next new Err.Api msg
    next!

function check-chronology edge, next
  # A given pair of nodes A-B can have multiple connections over non-overlapping time periods.
  # Here we check a given edge doesn't violate this rule.
  err, edges <~ M-Edges.find $or:
    * a_node_id:edge.a_node_id, b_node_id:edge.b_node_id, _id:$ne:(edge._id or \dummy)
    * a_node_id:edge.b_node_id, b_node_id:edge.a_node_id, _id:$ne:(edge._id or \dummy)
  return next err if err
  return next! unless edges
  try range1 = When.parse-range edge.when
  catch e then return next e
  for e in edges
    if When.is-overlap-ranges range1.int, (When.parse-range e.when).int
      return next new Err.Api "Edge.when #{edge.when} overlaps with existing edge.when #{e.when}"
  next!

function get-maps-having-edge id, cb
  err, edge <- M-Edges.findById id
  return cb err if err
  err, maps <- M-Maps.find!lean!exec
  return cb err if err
  cb void, _.filter maps, ->
    return false if edge.meta.create_date > it.edge_cutoff_date
    map-node-ids = _.map it.nodes, \_id
    (_.includes map-node-ids, edge.a_node_id) and (_.includes map-node-ids, edge.b_node_id)
