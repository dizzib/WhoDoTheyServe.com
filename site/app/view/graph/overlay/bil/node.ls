F = require \fs
C = require \../../../../collection
H = require \../../../../helper
E = require \./edge

H.insert-css F.readFileSync __dirname + \/node.css

const BADGE-SIZE-Y  = 16
const BADGE-SIZE-X  = 20
const BADGE-SPACE-X = 24

module.exports = me =
  init: (svg) ->
    svg.selectAll \g.node .each (node) ->
      edges = _.filter E.edges-attend, ->
        node._id is it.a_node_id or node._id is it.b_node_id
      edges = _.sortBy edges, -> it.yyyy
      offset-x = - (BADGE-SPACE-X * (edges.length - 1)) / 2
      for edge, i in edges
        evs = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
        ev1 = evs.length is 1
        url = if ev1 then evs.0.get \url else "#/edge/#{edge._id}"
        tip = if ev1 then "Evidence at Bilderberg #{edge.yyyy}" else ''
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
          .attr \target     , if ev1 then \_blank else ''
          .attr \xlink:href , -> url
          .attr \xlink:title, -> tip
          .append \svg:text
            .attr \dx, 2
            .attr \dy, 13
            .text -> edge.yy

  filter: (nodes) ->
    _.filter nodes, -> not me.is-conference-yyyy it

  is-annual-conference: ->
    'Bilderberg Annual Conference' is it.name

  is-conference-yyyy: ->
    /^Bilderberg Conference [0-9]{4}$/.test it.name

  is-steering: ->
    'Bilderberg Steering Committee' is it.name
