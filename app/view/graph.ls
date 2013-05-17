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
    render @el
    @$el.show!

function render el then
  $ el .empty!

  svg = d3.select el
    .append \svg
    .attr \width , WIDTH
    .attr \height, HEIGHT

  nodes = _.map C.Nodes.models, (x) -> x.attributes
  edges = _.map C.Edges.models, (x) -> x.attributes

  edges.forEach (edge) ->
    edge.source = _.find nodes, (n) -> n._id is edge.a_node_id
    edge.target = _.find nodes, (n) -> n._id is edge.b_node_id

  f = d3.layout.force!
    .nodes nodes
    .links edges
    .charge -1500
    .linkDistance 2
    .linkStrength 0.5
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
    .enter!
      .append \svg:circle
      .attr \class, \node
      .attr \r, (d) -> 5 + d.weight

  lines = svg.selectAll \line
    .data f.links!
    .enter!
      .append \svg:line
      .attr \class, \edge
      .attr \marker-end, (d) ->
        if d.a_is is \lt then 'url(#end)' else ''

  texts = svg.selectAll \text
    .data f.nodes!
    .enter!
      .append \svg:a
        .call f.drag
        .attr \xlink:href, (d) -> "#/node/#{d._id}"
        .append \svg:text
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

