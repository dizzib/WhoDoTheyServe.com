# draw convex hulls around certain clusters of nodes e.g. government departments

F   = require \fs
_   = require \underscore
H   = require \../../helper
Map = require \../../view .map

H.insert-css F.readFileSync __dirname + \/cluster.css

var clusters

Map
  ..on \cooled ->
    for c in clusters
      continue unless (hull = d3.geom.hull _.map c, -> [it.x, it.y]).length
      @svg.insert \svg:g, \.edge .attr \class, \hull # prepend as the lowest layer
        .append \path
          .style \stroke-linejoin, \round
          .style \stroke-width, 80
          .attr \d, "M#{hull.join \L}Z"

  ..on \pre-cool ->
    d3.selectAll \.hull .remove!

  ..on \render (ents) ->
    function get-servant-ids
      servants = []
      pending  = [it]
      while pending.length
        id = pending.shift!
        servant-edges = _.filter ents.edges, -> it.a_is_lt and it.b_node_id is id and it.class isnt \minor
        servant-ids = _.pluck servant-edges, \a_node_id
        servant-ids = _.difference servant-ids, servants # cycle prevention
        pending ++= servant-ids
        servants ++= servant-ids
      servants

    clusters := []
    for seed in (_.filter ents.nodes, -> /Government/.test it.name)
      ids = [seed._id] ++ get-servant-ids seed._id
      cluster = _.filter ents.nodes, -> it._id in ids
      clusters.push cluster
