# draw convex hulls around certain node regions e.g. governments
_ = require \underscore
H = require \../../../model/hive .instance

module.exports = (vg) ->
  var regions

  vg.on \cooled ->
    for r in regions
      continue unless (hull = d3.geom.hull _.map r.nodes, -> [it.x, it.y]).length
      @svg.insert \svg:g \.edge .attr \class "hull #{r.class}" # prepend as the lowest layer
        .append \path
          .style \stroke-linejoin \round
          .style \stroke-width 80
          .attr \d "M#{hull.join \L}Z"

  vg.on \pre-cool ->
    @svg?selectAll \.hull .remove!

  vg.on \pre-render (ents) ->
    regions := []
    edges = _.reject ents.edges, -> (_.intersection it.classes, <[ layer out-of-date ]>).length
    edges-a-is = _.groupBy edges, -> it.a_is
    edges-a-is.eq?by-a-node = _.groupBy edges-a-is.eq, -> it.a_node_id
    edges-a-is.eq?by-b-node = _.groupBy edges-a-is.eq, -> it.b_node_id
    return unless edges-a-is.lt?by-a-node = _.groupBy edges-a-is.lt, -> it.a_node_id
    return unless edges-a-is.lt?by-b-node = _.groupBy edges-a-is.lt, -> it.b_node_id
    nodes-free = _.indexBy (_.reject ents.nodes, -> it.is-person), \_id
    explicit-bosses = H.Map.get-prop \regions
    explicit-boss-node-ids = _.map explicit-bosses, -> it.id

    function get-region cls, node-ids
      class:cls, nodes:_.filter ents.nodes, -> it._id in node-ids

    function get-peer-node-ids subord-node-ids
      return [] unless edges-a-is.eq?
      peer-node-ids = []
      for id in subord-node-ids
        ids = _.pluck (edges-a-is.eq.by-a-node[id] or []), \b_node_id
        ids ++= _.pluck (edges-a-is.eq.by-b-node[id] or []), \a_node_id
        peer-node-ids ++= _.without ids, id
      _.uniq peer-node-ids

    function get-subord-node-ids node-id
      subords = []
      pending = [node-id]
      while pending.length
        id = pending.shift!
        ids = _.pluck edges-a-is.lt.by-b-node[id], \a_node_id
        ids = _.difference ids, subords # cycle prevention
        pending ++= ids
        subords ++= ids
      [node-id] ++ subords

    function get-boss-node-id node-id
      visited = {}
      until visited[node-id]
        edges = edges-a-is.lt.by-a-node[node-id]
        return node-id unless edges?length is 1
        return node-id unless nodes-free[b-node-id = edges.0.b_node_id]
        visited[node-id] = true
        node-id = b-node-id
      node-id # bail on cycle detection

    function push-implicit-regions # boss nodes seeked out at runtime
      while node = _.sample nodes-free
        boss-node-id = get-boss-node-id node._id
        subord-node-ids = get-subord-node-ids boss-node-id
        if subord-node-ids.length > 2
          unless (_.intersection subord-node-ids, explicit-boss-node-ids).length
            regions.push get-region '' subord-node-ids
            nodes-free[boss-node-id].classes.push \boss
        nodes-free := _.omit nodes-free, subord-node-ids

    function push-explicit-regions # boss nodes specified in config
      for boss in explicit-bosses when boss-node = nodes-free[boss.id]
        subord-node-ids = get-subord-node-ids boss.id
        peer-node-ids = get-peer-node-ids subord-node-ids
        subord-and-peer-node-ids = subord-node-ids ++ peer-node-ids
        if subord-node-ids.length > 2
          regions.push get-region boss.class, subord-node-ids
          regions.push get-region boss.class, subord-and-peer-node-ids
          boss-node.classes.push \boss
        nodes-free := _.omit nodes-free, subord-and-peer-node-ids

    push-explicit-regions!
    push-implicit-regions!
