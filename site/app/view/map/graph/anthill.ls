_  = require \underscore

module.exports = (vg, cursor) ->
  var cache, dn-edges-by-node-id, up-edges-by-node-id

  cursor.on \remove ->
    vg.svg.selectAll \.ants .classed \ants false

  cursor.on \render (id) ->
    ueids = get-uphill-edge-ids id
    deids = get-downhill-edge-ids id
    eids = ueids ++ deids
    sel = (_.map eids, -> ".edge.id_#it").join \,
    vg.svg.selectAll sel .classed \ants true if sel

  vg.on \late-render -> # build performance hashes
    cache := {}
    dn-edges-by-node-id := {}
    up-edges-by-node-id := {}
    @map.get \entities .edges.each ->
      (dn-edges-by-node-id[it.get \b_node_id] ||= []).push it if \lt is it.get \a_is
      (up-edges-by-node-id[it.get \a_node_id] ||= []).push it if \lt is it.get \a_is

  function get-downhill-edge-ids node-id, done = []
    return [] if _.contains done, node-id # infinite recursion guard
    done.push node-id
    return cache[node-id] if _.contains cache, node-id
    down-edges = dn-edges-by-node-id[node-id]
    down-edge-ids = _.map down-edges, -> it.id
    down-node-ids = _.map down-edges, -> it.get \a_node_id
    for nid in down-node-ids then down-edge-ids ++= get-downhill-edge-ids nid, done
    cache[node-id] = down-edge-ids
    down-edge-ids

  function get-uphill-edge-ids node-id, done = []
    return [] if _.contains done, node-id # infinite recursion guard
    done.push node-id
    return cache[node-id] if _.contains cache, node-id
    up-edges = up-edges-by-node-id[node-id]
    up-edge-ids = _.map up-edges, -> it.id
    up-node-ids = _.map up-edges, -> it.get \b_node_id
    for nid in up-node-ids then up-edge-ids ++= get-uphill-edge-ids nid, done
    cache[node-id] = up-edge-ids
    up-edge-ids
