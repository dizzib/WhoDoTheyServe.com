B  = require \backbone
F  = require \fs
_  = require \underscore
V  = require \../view
E  = require \./graph/edge
EG = require \./graph/edge-glyph
N  = require \./graph/node
OB = require \./graph/overlay/bil
OC = require \./graph/overlay/cfr

T = F.readFileSync __dirname + \/graph.html

const HEIGHT = 2500
const WIDTH  = 2500

overlays = [ OB, OC ]

module.exports = B.View.extend do
  init: ->
    refresh @el
    V.graph-toolbar.render!
  render: ->
    @scroll = @scroll or x:500, y:700
    $window = $ window
    B.once \route-before, ~>
      @scroll.x = $window.scrollLeft!
      @scroll.y = $window.scrollTop!
    @$el.show!
    _.defer ~> $window .scrollTop(@scroll.y) .scrollLeft(@scroll.x)

function refresh el then
  $ el .empty!
  svg = d3.select el .append \svg:svg
    .attr \width , WIDTH
    .attr \height, HEIGHT

  nodes = N.data!
  edges = E.data nodes
  edges = (OB.filter-edges >> OC.filter-edges) edges
  nodes = (OB.filter-nodes >> OC.filter-nodes) nodes

  f = d3.layout.force!
    .nodes nodes
    .links edges
    .charge -2000
    .friction 0.95
    .linkDistance -> 100
    .linkStrength E.get-strength
    .size [WIDTH, HEIGHT]
    .start!

  # order matters: svg uses painter's algo
  E .init svg, f
  N .init svg, f
  EG.init svg, f
  _.each overlays, -> it.init svg, f

  n-tick = 0
  f.on \end  , -> _.each overlays, -> it.render!
  f.on \start, -> _.each overlays, -> it.render-clear!
  f.on \tick, ->
    if n-tick++ % 4 is 0 then
      N .on-tick!
      E .on-tick!
      EG.on-tick!
