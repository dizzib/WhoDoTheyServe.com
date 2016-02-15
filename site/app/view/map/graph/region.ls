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

  vg.on \render (ents) ->
    edges-active = _.reject ents.edges, -> _.contains it.classes, \out-of-date
    edges-a-is   = _.groupBy edges-active, -> it.a_is
    edges-a-is.eq?by-a-node = _.groupBy edges-a-is.eq, -> it.a_node_id
    edges-a-is.eq?by-b-node = _.groupBy edges-a-is.eq, -> it.b_node_id
    edges-a-is.lt?by-b-node = _.groupBy edges-a-is.lt, -> it.b_node_id

    function get-node-ids-on-edges edges
      (_.pluck edges, \a_node_id) ++ (_.pluck edges, \b_node_id)

    function get-region cls, node-ids
      class:cls, nodes:_.filter ents.nodes, -> it._id in node-ids

    function get-peer-node-ids subord-node-ids
      ids = []
      for id in subord-node-ids
        peer-node-ids = get-node-ids-on-edges do
          (edges-a-is.eq?by-a-node[id] or []) ++ (edges-a-is.eq?by-b-node[id] or [])
        ids ++= _.without peer-node-ids, id
      _.uniq ids

    function get-subord-node-ids node-id
      subords = []
      pending = [node-id]
      while pending.length
        id = pending.shift!
        ids = get-node-ids-on-edges edges-a-is.lt?by-b-node[id]
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
