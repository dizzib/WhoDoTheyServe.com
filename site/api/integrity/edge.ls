_           = require \lodash
H           = require \../helper
M-Edges     = require \../model/edges
M-Maps      = require \../model/maps
M-Evidences = require \../model/evidences

module.exports =
  create: (req, res, next) ->
    err, obj <- M-Evidences.findOne entity_id:(b = req.body).a_node_id
    return next err if err
    return next new H.ApiError 'Cannot create an edge to a node lacking evidence' unless obj
    err, obj <- M-Evidences.findOne entity_id:b.b_node_id
    return next err if err
    return next new H.ApiError 'Cannot create an edge to a node lacking evidence' unless obj
    next!
  update: (req, res, next) ->
    return next! unless (b = req.body).a_node_id or b.b_node_id
    return next! if req.session.signin.role is \admin
    err, edge <- M-Edges.findById req.id
    return next err if err
    if b.a_node_id and edge.a_node_id isnt b.a_node_id then
      return next new H.ApiError 'Only admin can update a_node_id'
    if b.b_node_id and edge.b_node_id isnt b.b_node_id then
      return next new H.ApiError 'Only admin can update b_node_id'
    next!
  delete: (req, res, next) ->
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete an evidenced edge' if obj
    err, maps-having-edge <- get-maps-having-edge req.id
    return next err if err
    if maps-having-edge.length > 0
      map-names = (_.map maps-having-edge, -> it.name).join ', '
      msg = "Cannot delete edge because it appears on the following maps: #map-names"
      return next new H.ApiError msg
    next!

function get-maps-having-edge id, cb
  err, edge <- M-Edges.findById id
  return cb err if err
  err, maps <- M-Maps.find!lean!exec
  return cb err if err
  cb void, _.filter maps, ->
    return false if edge.meta.create_date > it.edge_cutoff_date
    map-node-ids = _.pluck it.nodes, \_id
    (_.contains map-node-ids, edge.a_node_id) and (_.contains map-node-ids, edge.b_node_id)
