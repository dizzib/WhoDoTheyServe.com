B = require \backbone
F = require \fs
I = require \../lib-3p/insert-css
V = require \../view
G-Edge      = require \./graph/edge
G-EdgeBBerg = require \./graph/bberg/edge
G-EdgeCfr   = require \./graph/cfr/edge
G-EdgeGlyph = require \./graph/edge-glyph
G-Node      = require \./graph/node
G-NodeBBerg = require \./graph/bberg/node
G-NodeCfr   = require \./graph/cfr/node

I F.readFileSync __dirname + \/graph.css
T = F.readFileSync __dirname + \/graph.html

const HEIGHT = 2000
const WIDTH  = 2000
const CLASS-BBERG-ATTEND = \bberg-attend
const CLASS-BBERG-STEER  = \bberg-steer
const CLASS-CFR          = \cfr

scroll-pos = x:500, y:700

module.exports = B.View.extend do
  init: ->
    refresh @el
    add-handler \toggle-bberg-attend, CLASS-BBERG-ATTEND
    add-handler \toggle-bberg-steer , CLASS-BBERG-STEER
    add-handler \toggle-cfr         , CLASS-CFR
    function add-handler event, css-class
      V.graph-toolbar.on event, ->
        d3.select "g.#{css-class}" .attr \display, if it then '' else \none
    V.graph-toolbar.render!
  render: ->
    $window = $ window
    B.once \route-before, ->
      scroll-pos.x = $window.scrollLeft!
      scroll-pos.y = $window.scrollTop!
    @$el.show!
    $window .scrollTop(scroll-pos.y) .scrollLeft(scroll-pos.x)

function refresh el then
  $ el .empty!
  svg = create-svg!

  # overlays -- order matters: svg uses painter's algo
  g-bberg-attend = svg.append \svg:g .attr \class, CLASS-BBERG-ATTEND
  g-bberg-steer  = svg.append \svg:g .attr \class, CLASS-BBERG-STEER
  g-cfr          = svg.append \svg:g .attr \class, CLASS-CFR

  nodes = G-Node.data!
  edges = G-Edge.data nodes
  nodes = G-NodeBBerg.filter-out nodes
  edges = G-EdgeBBerg.filter-out edges
  edges = G-EdgeCfr.filter-out edges

  f = d3.layout.force!
    .nodes nodes
    .links edges
    .charge -2000
    .friction 0.95
    .linkDistance -> 50
    .linkStrength G-Edge.get-strength
    .size [WIDTH, HEIGHT]
    .start!

  # order matters: svg uses painter's algo
  G-Edge.init svg, f
  G-Node.init svg, f
  G-NodeBBerg.init svg, f
  G-NodeCfr.init svg, f
  G-EdgeGlyph.init svg, f

  n-tick = 0
  f.on \start, ->
    G-EdgeBBerg.render-clear!
    G-EdgeCfr.render-clear!
  f.on \end, ->
    G-EdgeBBerg.render-attend g-bberg-attend, f
    G-EdgeBBerg.render-steer  g-bberg-steer , f
    G-EdgeCfr.render g-cfr, f
  f.on \tick, ->
    tick! if n-tick++ % 4 is 0

  function create-svg css-class then
    d3.select el
      .append \svg:svg
      .attr \class , css-class
      .attr \width , WIDTH
      .attr \height, HEIGHT

  function tick then
    G-Node.on-tick!
    G-Edge.on-tick!
    G-EdgeGlyph.on-tick!
