B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
H = require \../helper
I = require \../lib-3p/insert-css

I F.readFileSync __dirname + \/graph.css
T = F.readFileSync __dirname + \/graph.html

const ICON-SIZE = 16
const HEIGHT    = 940
const WIDTH     = 940

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
    source: _.find nodes, -> it._id is x.get \a_node_id
    target: _.find nodes, -> it._id is x.get \b_node_id

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
      .attr \r, -> 5 + it.weight

  lines = svg.selectAll \line
    .data f.links!
    .enter!append \svg:line
      .attr \class, -> "edge #{if is-out-of-range it then \minor else ''}".trim!
      .attr \marker-end, -> if it.a_is is \lt then 'url(#end)' else ''

  line-glyphs = svg.selectAll \g.edge-glyphs
    .data f.links!
    .enter!append \svg:g
      .attr \class, \edge-glyphs

  line-glyphs
    .each (edge) ->
      evs = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
      dx = - ((ICON-SIZE + 1) * (evs.length - 1)) / 2
      for ev, i in evs
        d3.select this
          .append \svg:a
            .attr \target, \_blank
            .attr \xlink:href, -> ev.get \url
            .append \svg:image
              .attr \xlink:href, \asset/camera.svg
              .attr \x , dx + i * (ICON-SIZE + 1)
              .attr \width , ICON-SIZE
              .attr \height, ICON-SIZE

  texts = svg.selectAll \text
    .data f.nodes!
    .enter!append \svg:a
      .call f.drag
      .attr \xlink:href, -> "#/node/#{it._id}"
      .append \svg:text
        .attr \dy, \0.2em
        .attr \text-anchor, \middle
        .text -> it.name

  f.on \tick, ->
    circs
      .attr \cx, -> it.x
      .attr \cy, -> it.y
    line-glyphs
      .attr \transform, ->
        x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
        y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
        "translate(#{x},#{y})"
    lines
      .attr \x1, -> it.source.x
      .attr \y1, -> it.source.y
      .attr \x2, -> it.target.x
      .attr \y2, -> it.target.y
    texts
      .attr \x, -> it.x
      .attr \y, -> it.y

  function is-out-of-range edge then
    const RANGE =
      year_from: 2011
      year_to  : 2013
    year_from = edge.year_from
    year_to   = edge.year_to or 9999
    return year_to < RANGE.year_from or RANGE.year_to < year_from
