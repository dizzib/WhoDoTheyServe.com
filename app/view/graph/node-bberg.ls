F = require \fs
C = require \../../collection
I = require \../../lib-3p/insert-css

I F.readFileSync __dirname + \/node-bberg.css

const BADGE-SIZE-Y  = 16
const BADGE-SIZE-X  = 20
const BADGE-SPACE-X = 24

exports
  ..init = (svg, d3-force) ~>
    svg.selectAll \g.nodes .each (node) ->
      edges = _.filter C.Edges.models, ->
        a_node = C.Nodes.get(a_node_id = it.get \a_node_id).attributes
        b_node = C.Nodes.get(b_node_id = it.get \b_node_id).attributes
        return
          (node._id is a_node_id and exports.is-bberg-conference b_node) or
          (node._id is b_node_id and exports.is-bberg-conference a_node)
      edges = _.sortBy edges, -> it.get \year_from
      offset-x = - (BADGE-SPACE-X * (edges.length - 1)) / 2
      for edge, i in edges
        evs = _.filter C.Evidences.models, -> edge.id is it.get \entity_id
        url = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge.id}"
        tip = if evs.length is 1 then "Evidence at Bilderberg #{edge.get \year_from}" else ''
        dx  = offset-x + (i * BADGE-SPACE-X) - (BADGE-SIZE-X / 2)
        d3-node = d3.select this
        d3-node.append \svg:rect
          .attr \class , \bberg-badge
          .attr \height, BADGE-SIZE-Y
          .attr \width , BADGE-SIZE-X
          .attr \rx    , 5
          .attr \ry    , 5
          .attr \x     , dx
          .attr \y     , 10
        d3-node.append \svg:a
          .attr \target     , \_blank
          .attr \xlink:href , -> url
          .attr \xlink:title, -> tip
          .append \svg:text
            .attr \class, \bberg-badge-text
            .attr \dx   , dx + 2
            .attr \dy   , 23
            .text -> (edge.get \year_from).toString!substring 2

  ..filter-out = (nodes) ->
    _.filter nodes, -> not exports.is-bberg-conference it

  ..is-bberg-conference = (node) ->
      /^Bilderberg Conference [0-9]{4}$/.test node.name
