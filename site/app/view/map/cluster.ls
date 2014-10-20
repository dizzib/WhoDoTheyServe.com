# draw convex hulls around certain clusters of nodes e.g. government departments
_   = require \underscore
Map = require \../../view .map

var clusters

Map.on \cooled ->
  for c in clusters
    continue unless (hull = d3.geom.hull _.map c, -> [it.x, it.y]).length
    @svg.insert \svg:g, \.edge .attr \class, \hull # prepend as the lowest layer
      .append \path
        .style \stroke-linejoin, \round
        .style \stroke-width, 80
        .attr \d, "M#{hull.join \L}Z"

Map.on \pre-cool ->
  d3.selectAll \.hull .remove!

Map.on \render (ents) ->
  # loose filter includes subordinates and peers
  function filter-loose node-id, edge
    (filter-tight node-id, edge) or
    (edge.a_is_eq and (node-id is edge.a_node_id or node-id is edge.b_node_id))

  # tight filter only includes subordinates
  function filter-tight node-id, edge
    edge.a_is_lt and edge.b_node_id is node-id

  function get-cluster seed-id, filter
    function get-servant-ids
      servants = []
      pending  = [seed-id]
      while pending.length
        id = pending.shift!
        servant-edges = _.filter ents.edges, -> it.class isnt \minor and filter id, it
        servant-ids = (_.pluck servant-edges, \a_node_id) ++ _.pluck servant-edges, \b_node_id
        servant-ids = _.difference servant-ids, servants # cycle prevention
        pending ++= servant-ids
        servants ++= servant-ids
      servants

    ids = [seed._id] ++ get-servant-ids!
    _.filter ents.nodes, -> it._id in ids

  clusters := []
  for seed in (_.filter ents.nodes, -> /Government/.test it.name)
    # both hulls are stacked, the loose one extending further out
    clusters.push get-cluster seed._id, filter-loose
    clusters.push get-cluster seed._id, filter-tight
