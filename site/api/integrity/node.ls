_           = require \lodash
H           = require \../helper
M-Edges     = require \../model/edges
M-Evidences = require \../model/evidences
M-Maps      = require \../model/maps
M-Nodes     = require \../model/nodes

module.exports =
  update: (req, res, next) ->
    return next! if req.session.signin.role is \admin
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot update an evidenced node' if obj
    err, maps-having-node <- get-maps-having-node req.id
    return next err if err
    maps-not-my-own = _.filter maps-having-node, -> it.meta.create_user_id isnt req.session.signin.id
    if maps-not-my-own.length > 0
      map-names = (_.map maps-not-my-own, -> it.name).join ', '
      msg = "Cannot update node because it appears on the following maps by other users: #map-names"
      return next new H.ApiError msg
    next!
  delete: (req, res, next) ->
    err, obj <- M-Edges.findOne $or:
      * a_node_id:req.id
      * b_node_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete a node with edges' if obj
    err, obj <- M-Evidences.findOne entity_id:req.id
    return next err if err
    return next new H.ApiError 'Cannot delete an evidenced node' if obj
    err, maps-having-node <- get-maps-having-node req.id
    return next err if err
    if maps-having-node.length > 0
      map-names = (_.map maps-having-node, -> it.name).join ', '
      msg = "Cannot delete node because it appears on the following maps: #map-names"
      return next new H.ApiError msg
    next!

function get-maps-having-node id, cb
  err, maps <- M-Maps.find!lean!exec
  return cb err if err
  cb void, _.filter maps, -> (_.contains (_.pluck it.nodes, \_id), id)
