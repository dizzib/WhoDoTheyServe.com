B  = require \backbone
Fs = require \fs
_  = require \underscore
C  = require \../collection
E  = require \./graph/edge
Eg = require \./graph/edge-glyph
Fz = require \./graph/freezer
N  = require \./graph/node
O  = require \./graph/overlay
Ob = require \./graph/overlay/bil
Os = require \./graph/overlay/slit
P  = require \./graph/persister
V  = require \../view

T = Fs.readFileSync __dirname + \/graph.html

const SIZE = 3000

overlays = [ Ob, O.Ac, O.Bis, O.Cfr ]

module.exports = B.View.extend do
  init: ->
    return unless @el # might be undefined for seo
    refresh @el, f = d3.layout.force!
    V.graph-toolbar
      ..render!
      ..on \save-layout, -> P.save-layout f
  render: ->
    @scroll = @scroll or x:0, y:0
    $window = $ window
    B.once \route-before, ~>
      @scroll.x = $window.scrollLeft!
      @scroll.y = $window.scrollTop!
    @$el.show!
    _.defer ~> $window .scrollTop(@scroll.y) .scrollLeft(@scroll.x)

function refresh el, f then
  $ el .empty!
  svg = d3.select el .append \svg:svg
    .attr \width , SIZE
    .attr \height, SIZE

  nodes = N.data!
  edges = E.data nodes

  # prevent D3 error "Cannot read property 'length'" when nodes or edges
  # is empty, typically at start of app integration tests
  return unless nodes?length and edges?length

  edges = (Ob.filter-edges >> O.Ac.filter-edges >> O.Bis.filter-edges >> O.Cfr.filter-edges) edges
  nodes = (Ob.filter-nodes >> P.apply-layout >> Fz.fix-unless-admin) nodes

  f.nodes nodes
   .links edges
   .charge -2000
   .friction 0.95
   .linkDistance 100
   .linkStrength E.get-strength
   .size [SIZE, SIZE]
   .start!

  if P.is-persisted! then f.alpha 0.01 # settle immediately (must invoke after start)

  # order matters: svg uses painter's algo
  E .init svg, f
  N .init svg, f
  Os.init svg, f
  Eg.init svg, f
  _.each overlays, -> it.init svg, f

  Fz.make-draggable-if-admin svg, f
  Os.align svg, f

  n-tick = 0
  f.on \end  , -> _.each overlays, -> it.render!
  f.on \start, -> _.each overlays, -> it.render-clear!
  f.on \tick, ->
    if n-tick++ % 4 is 0 then
      N .on-tick!
      E .on-tick!
      Eg.on-tick!
