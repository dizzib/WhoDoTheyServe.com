B  = require \backbone
Fs = require \fs
_  = require \underscore
C  = require \../collection
E  = require \./map/edge
Eg = require \./map/edge-glyph
N  = require \./map/node
O  = require \./map/overlay
Ob = require \./map/overlay/bil
Os = require \./map/overlay/slit
H  = require \../helper
S  = require \../session
V  = require \../view

H.insert-css Fs.readFileSync __dirname + \/map.css

const SIZE-NEW = 500px
const OVERLAYS = [ Ob, O.Ac, O.Bis, O.Cfr ]

module.exports = B.View.extend do
  get-nodes-xy: ->
    _.map @f.nodes!, ->
      _id: it._id
      x  : Math.round it.x
      y  : Math.round it.y

  get-size-x: -> @svg?attr \width
  get-size-y: -> @svg?attr \height

  initialize: ->
    n-tick = 0
    is-resized = false
    @f = d3.layout.force!
      ..on \start, ~>
        render-start @
        is-resized := false
      ..on \tick , ~>
        return unless n-tick++ % 4 is 0
        on-tick!
        if @map.get-is-editable! and not is-resized and @f.alpha! < 0.03
          set-map-size @
          is-resized := true # resize only once during cool-down
      ..on \end  , ~> render-stop @

  refresh-entities: (node-ids) -> # client-side version of server-side model/maps.ls
    return unless node-ids.length isnt (@map.get \nodes)?length
    # node coords
    nodes = @f.nodes!
    @map.set \nodes, _.map node-ids, (nid) ~>
      node = _.find nodes, -> it._id is nid
      _id: nid
      x  : node?x or @get-size-x!/2 # add new node to center
      y  : node?y or @get-size-y!/2
    # entities
    nodes = C.Nodes.filter -> _.contains node-ids, it.id
    edges = C.Edges.filter ~>
      return false unless it.is-in-map node-ids
      return true unless edge-cutoff-date = @map.get \edge_cutoff_date
      edge-cutoff-date > it.get \meta .create_date
    @map.set \entities,
      nodes: _.pluck nodes, \attributes
      edges: _.pluck edges, \attributes
    true

  render: (opts) ->
    return unless @el # might be undefined for seo
    @$el.empty!
    # clone entities so the originals don't get filtered out, as they may be used elsewhere
    return unless entities = _.deepClone @map.get \entities
    return unless (nodes = entities.nodes)?length

    edges = E.data entities
    edges = (Ob.filter-edges >> O.Ac.filter-edges >> O.Bis.filter-edges >> O.Cfr.filter-edges) edges
    nodes = Ob.filter-nodes nodes

    is-editable = @map.get-is-editable!
    _.each nodes, -> it.fixed = (not is-editable) or N.is-you it

    size-x = @map.get \size-x or @get-size-x! or SIZE-NEW
    size-y = @map.get \size-y or @get-size-y! or SIZE-NEW

    unless @map.isNew!
      for n in @map.get \nodes when n.x?
        node = _.findWhere nodes, _id:n._id
        node <<< { x:n.x, y:n.y } if node?

    @f.nodes nodes
     .links (edges or [])
     .charge -2000
     .friction 0.85
     .linkDistance 100
     .linkStrength E.get-strength
     .size [size-x, size-y]
     .start!

    @svg = d3.select @el .append \svg:svg
    set-canvas-size @svg, size-x, size-y
    justify @

    # order matters: svg uses painter's algo
    E .init @svg, @f
    N .init @svg, @f
    Os.init @svg, @f
    Eg.init @svg, @f, entities.evidences
    _.each OVERLAYS, ~> it.init @svg, @f

    @svg.selectAll \g.node .call @f.drag if is-editable
    Os.align @svg, @f

    # determine whether to freeze immediately
    return if @map.isNew!
    return if opts?is-slow-to-cool

    @f.alpha 0 # freeze map -- must be called after start
    on-tick!   # single tick required to render frozen map

  show: ->
    return unless @el # might be undefined for seo
    @scroll = @scroll or x:0, y:0
    $window = $ window
    B.once \route-before, ~>
      @scroll.x = $window.scrollLeft!
      @scroll.y = $window.scrollTop!
    @$el.show!
    justify @
    _.defer ~> $window .scrollTop(@scroll.y) .scrollLeft(@scroll.x)

# helpers

function on-tick
  N .on-tick!
  E .on-tick!
  Eg.on-tick!

function justify v
  return unless (g = $ '.view>.map').is \:visible # prevent show if it's hidden
  return unless v.svg # might be undefined e.g. new map
  # only apply flex if svg needs centering, due to bugs in flex when content exceeds container width
  if v.svg.attr \width < g.width!
    g.css \display, \flex
    g.css \align-items, \center # vert
    g.css \justify-content, \center # horiz
  else
    g.css \display, \block
    g.css \justify-content, \flex-start

function render-start v
  v.trigger \render
  _.each OVERLAYS, -> it.render-clear!

function render-stop v
  _.each OVERLAYS, -> it.render!
  v.trigger \rendered

function set-canvas-size svg, w, h
  svg.attr \width, w .attr \height, h

function set-map-size v
  const PADDING = 200px

  nodes = v.get-nodes-xy!
  xs = _.map nodes, -> it.x
  ys = _.map nodes, -> it.y
  w  = (_.max xs) - (xmin = _.min xs) + 2 * PADDING
  h  = (_.max ys) - (ymin = _.min ys) + 2 * PADDING

  set-canvas-size v.svg, w, h
  justify v
  v.f.size [w, h]
