_           = require \lodash
H           = require \./helper
M-Edges     = require \./model/edges
M-Maps      = require \./model/maps
M-Nodes     = require \./model/nodes
M-Evidences = require \./model/evidences

module.exports =
  edge-create: (req, res, next) ->
    err, obj <- M-Evidences.findOne entity_id:(b = req.body).a_node_id
    return next err if err
    return next new H.ApiError 'Cannot create an edge to a node lacking evidence' unless obj
    err, obj <- M-Evidences.findOne entity_id:b.b_node_id
    return next err if err
    return next new H.ApiError 'Cannot create an edge to a node lacking evidence' unless obj
    get-checker-create(M-Edges) req, res, next
  edge-update: (req, res, next) ->
    return next! unless (b = req.body).a_node_id or b.b_node_id
    return next! if req.session.signin.role is \admin
    err, edge <- M-Edges.findById req.id
    return next err if err
    if b.a_node_id and edge.a_node_id isnt b.a_node_id then
      return next new H.ApiError 'Only admin can update a_node_id'
    if b.b_node_id and edge.b_node_id isnt b.b_node_id then
      return next new H.ApiError 'Only admin can update b_node_id'
    next!
  edge-delete: (req, res, next) ->
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete an evidenced edge' if obj
    next!
  node-create: get-checker-create M-Nodes
  node-update: (req, res, next) ->
    return next! if req.session.signin.role is \admin
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot update an evidenced node' if obj
    next!
  node-delete: (req, res, next) ->
    err, obj <- M-Edges.findOne $or:
      * a_node_id:req.id
      * b_node_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete a node with edges' if obj
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete an evidenced node' if obj
    err, maps <- M-Maps.find!lean!exec
    return next err if err
    if (maps-ref = _.filter maps, -> (_.contains (_.pluck it.nodes, \_id), req.id)).length > 0
      map-names = (_.map maps-ref, -> it.name).join ', '
      msg = "Cannot delete node because it appears on the following maps: #map-names"
      return next new H.ApiError msg
    next!

function get-checker-create Model then (req, res, next) ->
  err, docs <- Model.find {'meta.create_user_id':req.session.signin.id}, \_id
  return next err if err
  err, evs <- M-Evidences.find entity_id: $in:ids = _.map docs, -> it._id
  return next err if err
  entity-ids = _.unique _.map evs, -> it.entity_id.toString!
  if (n-no-evidence = ids.length - entity-ids.length) > 0
    return next new H.ApiError "Cannot create while #{n-no-evidence} of your other #{Model.modelName} are missing evidence"
  next!
