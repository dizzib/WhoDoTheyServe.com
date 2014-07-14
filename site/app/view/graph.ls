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

const OVERLAYS = [ Ob, O.Ac, O.Bis, O.Cfr ]
const SIZE = 1500

module.exports = B.View.extend do
  show: (map) ->
    return unless @el # might be undefined for seo
    log \show

    @scroll = @scroll or x:0, y:0
    $window = $ window
    B.once \route-before, ~>
      @scroll.x = $window.scrollLeft!
      @scroll.y = $window.scrollTop!
    @$el.show!
    _.defer ~> $window .scrollTop(@scroll.y) .scrollLeft(@scroll.x)

  render: (map) ->
    return unless @el # might be undefined for seo
    log \render
    @$el.empty!

    return unless entities = map.attributes.entities
    return unless (nodes = entities.nodes)?length
    return unless (edges = E.data entities)?length

    edges = (Ob.filter-edges >> O.Ac.filter-edges >> O.Bis.filter-edges >> O.Cfr.filter-edges) edges
    nodes = (Ob.filter-nodes >> P.apply-layout >> Fz.fix-unless-admin) nodes

    svg = d3.select @el .append \svg:svg
    f = d3.layout.force!
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
    _.each OVERLAYS, -> it.init svg, f

    Fz.make-draggable-if-admin svg, f
    Os.align svg, f

    n-tick = 0
    f.on \start, ->
      _.each OVERLAYS, -> it.render-clear!
    f.on \tick, ->
      if n-tick++ % 4 is 0 then
        N .on-tick!
        E .on-tick!
        Eg.on-tick!
    f.on \end  , ->
      _.each OVERLAYS, -> it.render!
      svg
        .attr \width , SIZE
        .attr \height, SIZE

    V.graph-toolbar.render!
