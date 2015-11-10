_  = require \underscore
C  = require \../../../collection

module.exports = (vg, cursor) ->
  cache = {}

  cursor.on \hide ->
    vg.svg.selectAll \.ants .classed \ants false

  cursor.on \show ->
    ueids = get-uphill-edge-ids it._id
    deids = get-downhill-edge-ids it._id
    eids = ueids ++ deids
    sel = (_.map eids, -> ".id_#it:not(.out-of-date)").join \,
    vg.svg.selectAll sel .classed \ants true if sel

  function get-downhill-edge-ids node-id, done = []
    return [] if _.contains done, node-id # infinite recursion guard
    done.push node-id
    return cache[node-id] if _.contains cache, node-id
    down-edges = C.Edges.where b_node_id:node-id, a_is:\lt
    down-edge-ids = _.map down-edges, -> it.id
    down-node-ids = _.map down-edges, -> it.get \a_node_id
    for nid in down-node-ids then down-edge-ids ++= get-downhill-edge-ids nid, done
    cache[node-id] = down-edge-ids
    down-edge-ids

  function get-uphill-edge-ids node-id, done = []
    return [] if _.contains done, node-id # infinite recursion guard
    done.push node-id
    return cache[node-id] if _.contains cache, node-id
    up-edges = C.Edges.where a_node_id:node-id, a_is:\lt
    up-edge-ids = _.map up-edges, -> it.id
    up-node-ids = _.map up-edges, -> it.get \b_node_id
    for nid in up-node-ids then up-edge-ids ++= get-uphill-edge-ids nid, done
    cache[node-id] = up-edge-ids
    up-edge-ids
