B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
H = require \../helper
I = require \../lib-3p/insert-css

I F.readFileSync __dirname + \/graph.css
T = F.readFileSync __dirname + \/graph.html

const HEIGHT = 940
const WIDTH  = 940

module.exports = B.View.extend do
  render: ->
    refresh @el
    @$el.show!

function refresh el then
  $ el .empty!
  svg = d3.select el
    .append \svg
    .attr \width , WIDTH
    .attr \height, HEIGHT

  nodes = _.map C.Nodes.models, (x) -> _.extend do
    x.attributes
    edge-count: 0

  edges = _.map C.Edges.models, (x) -> _.extend do
    x.attributes
    source: _.find nodes, (n) -> n._id is x.get \a_node_id
    target: _.find nodes, (n) -> n._id is x.get \b_node_id

  for edge in edges
    edge.source.edge-count++
    edge.target.edge-count++

  f = d3.layout.force!
    .nodes nodes
    .links edges
    .charge -1500
    .friction 0.95
    .linkDistance -> 50
    .linkStrength -> 10 / (it.source.edge-count + it.target.edge-count)
    .size [WIDTH, HEIGHT]
    .start!

  svg.append \svg:defs .selectAll \marker
    .data <[ end ]>
    .enter!append \svg:marker
      .attr \id, String
      .attr \viewBox, '0 -5 10 10'
      .attr \refX, 20
      .attr \markerWidth, 10
      .attr \markerHeight, 10
      .attr \orient, \auto
    .append \svg:path
      .attr \d, 'M0,-5L10,0L0,5'

  circs = svg.selectAll \circle
    .data f.nodes!
    .enter!append \svg:circle
      .attr \class, \node
      .attr \r, (d) -> 5 + d.weight

  lines = svg.selectAll \line
    .data f.links!
    .enter!append \svg:line
      .attr \class, (d) -> "edge #{if out-of-range d then \out-of-range}"
      .attr \marker-end, (d) ->
        if d.a_is is \lt then 'url(#end)' else ''

  texts = svg.selectAll \text
    .data f.nodes!
    .enter!append \svg:a
      .call f.drag
      .attr \xlink:href, (d) -> "#/node/#{d._id}"
      .append \svg:text
        .attr \dy, \0.2em
        .attr \text-anchor, \middle
        .text (d) -> d.name

  f.on \tick, ->
    circs
      .attr \cx, (d) -> d.x
      .attr \cy, (d) -> d.y
    lines
      .attr \x1, (d) -> d.source.x
      .attr \y1, (d) -> d.source.y
      .attr \x2, (d) -> d.target.x
      .attr \y2, (d) -> d.target.y
    texts
      .attr \x, (d) -> d.x
      .attr \y, (d) -> d.y

  function out-of-range edge then
    const RANGE =
      year_from: 2011
      year_to  : 2013
    year_from = edge.year_from
    year_to   = edge.year_to or 9999
    return year_to < RANGE.year_from or RANGE.year_to < year_from
