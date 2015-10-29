# draw convex hulls around certain node regions e.g. governments
_ = require \underscore
H = require \../../model/hive .instance

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
    d3.selectAll \.hull .remove!

  vg.on \render (ents) ->
    function get-region cls, node-ids
      class:cls, nodes:_.filter ents.nodes, -> it._id in node-ids

    function get-node-ids id, filter
      edges = _.filter ents.edges, -> it.class isnt \minor and filter id, it
      (_.pluck edges, \a_node_id) ++ _.pluck edges, \b_node_id

    function get-peer-node-ids subord-node-ids
      function filter node-id, edge
        edge.a_is_eq and (node-id is edge.a_node_id or node-id is edge.b_node_id)
      ids = []
      for id in subord-node-ids
        peer-node-ids = get-node-ids id, filter
        ids ++= _.without peer-node-ids, id
      _.uniq ids

    function get-subord-node-ids node-id
      function filter node-id, edge then edge.a_is_lt and edge.b_node_id is node-id
      subords = []
      pending = [node-id]
      while pending.length
        id = pending.shift!
        ids = get-node-ids id, filter
        ids = _.difference ids, subords # cycle prevention
        pending ++= ids
        subords ++= ids
      [node-id] ++ subords

    regions := []
    for seed-node in H.Map.get-prop \regions
      subord-node-ids = get-subord-node-ids seed-node.id
      peer-node-ids = get-peer-node-ids subord-node-ids
      regions.push get-region seed-node.class, subord-node-ids
      regions.push get-region seed-node.class, subord-node-ids ++ peer-node-ids
