Eve = require \events .EventEmitter
_   = require \underscore

module.exports = me = (new Eve!) with init: (vg) ->
  vg.on \render ->
    @$el.off \click refresh # otherwise handler runs against old svg in closure
    @$el.on  \click refresh

    ## helpers

    ~function find-nearby-node x, y
      const RADIUS = 100px
      function is-near x0, x1, y0, y1 # rough but fast initial proximity test
        Math.abs(x1 - x0) < RADIUS and Math.abs(y1 - y0) < RADIUS
      function get-distance x0, x1, y0, y1
        ((x1 - x0) ^ 2) + ((y1 - y0) ^ 2) # for performance no need to Math.sqrt
      near-nodes = _.filter @d3f.nodes!, -> is-near it.x, x, it.y, y
      dists = _.map near-nodes, -> node:it, d:get-distance it.x, x, it.y, y
      min = _.min dists, -> it.d
      min.node if min.d < RADIUS ^ 2

    function get-cursor-path
      function get-segment sign-x, sign-y
        const RADIUS = 32px
        const LENGTH = 8px
        px = RADIUS * sign-x
        py = RADIUS * sign-y
        qx = px + LENGTH * sign-x
        qy = py + LENGTH * sign-y
        "M #px #py L #px #qy L #qx #py L #px #py "
      get-segment(+1, +1) + get-segment(+1, -1) + get-segment(-1, +1) + get-segment(-1, -1)

    ~function refresh
      @svg.select \.cursor .remove!
      me.emit \hide
      return unless nd = find-nearby-node it.offsetX, it.offsetY
      id = nd._id
      n = @svg.select "g.node.id_#id"
      n.append \svg:path
        .attr \class \cursor
        .attr \d get-cursor-path!
      me.emit \show nd
