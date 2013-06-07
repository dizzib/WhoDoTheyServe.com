B = require \backbone
F = require \fs
I = require \../lib-3p/insert-css
G-Edge      = require \./graph/edge
G-EdgeBBerg = require \./graph/edge-bberg
G-EdgeGlyph = require \./graph/edge-glyph
G-Node      = require \./graph/node
G-NodeBBerg = require \./graph/node-bberg

I F.readFileSync __dirname + \/graph.css
T = F.readFileSync __dirname + \/graph.html

const HEIGHT = 1500
const WIDTH  = 2000

scroll-pos = x:500, y:500

module.exports = B.View.extend do
  init: ->
    refresh @el
  render: ->
    $window = $ window
    B.once \route-before, ->
      scroll-pos.x = $window.scrollLeft!
      scroll-pos.y = $window.scrollTop!
    @$el.show!
    $window .scrollTop(scroll-pos.y) .scrollLeft(scroll-pos.x)

function refresh el then
  $ el .empty!

  svg-underlay = create-svg!
  svg          = create-svg!

  nodes = G-Node.data!
  edges = G-Edge.data nodes
  nodes = G-NodeBBerg.filter-out nodes
  edges = G-EdgeBBerg.filter-out edges

  f = d3.layout.force!
    .nodes nodes
    .links edges
    .charge -1500
    .friction 0.95
    .linkDistance -> 50
    .linkStrength G-Edge.get-strength
    .size [WIDTH, HEIGHT]
    .start!

  # order matters: svg uses painter's algo
  G-Edge.init svg, f
  G-Node.init svg, f
  G-NodeBBerg.init svg, f
  G-EdgeGlyph.init svg, f

  f.on \start, -> G-EdgeBBerg.render-clear svg-underlay
  f.on \end  , -> G-EdgeBBerg.render svg-underlay, f
  f.on \tick , ->
    G-Node.on-tick!
    G-Edge.on-tick!
    G-EdgeGlyph.on-tick!

  function create-svg then
    d3.select el
      .append \svg:svg
      .attr \width , WIDTH
      .attr \height, HEIGHT
