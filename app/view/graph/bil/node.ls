F = require \fs
C = require \../../../collection
I = require \../../../lib-3p/insert-css
E = require \./edge

I F.readFileSync __dirname + \/node.css

const BADGE-SIZE-Y  = 16
const BADGE-SIZE-X  = 20
const BADGE-SPACE-X = 24

exports
  ..init = (svg, d3-force) ->
    svg.selectAll \g.node .each (node) ->
      edges = _.filter E.edges-attend, ->
        node._id is it.a_node_id or node._id is it.b_node_id
      edges = _.sortBy edges, -> it.year_from
      offset-x = - (BADGE-SPACE-X * (edges.length - 1)) / 2
      for edge, i in edges
        evs = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
        url = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge._id}"
        tip = if evs.length is 1 then "Evidence at Bilderberg #{edge.year_from}" else ''
        dx  = offset-x + (i * BADGE-SPACE-X) - (BADGE-SIZE-X / 2)
        badge = d3.select this .append \svg:g
          .attr \class, \badge-bil
          .attr \transform, -> "translate(#{dx},10)"
        badge.append \svg:rect
          .attr \height, BADGE-SIZE-Y
          .attr \width , BADGE-SIZE-X
          .attr \rx    , 5
          .attr \ry    , 5
        badge.append \svg:a
          .attr \target     , \_blank
          .attr \xlink:href , -> url
          .attr \xlink:title, -> tip
          .append \svg:text
            .attr \dx, 2
            .attr \dy, 13
            .text -> (edge.year_from).toString!substring 2

  ..filter-out = (nodes) ->
    _.filter nodes, -> not exports.is-conference-yyyy it

  ..is-annual-conference = ->
    'Bilderberg Annual Conference' is it.name

  ..is-conference-yyyy = ->
    /^Bilderberg Conference [0-9]{4}$/.test it.name

  ..is-steering = ->
    'Bilderberg Steering Committee' is it.name
