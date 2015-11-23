Eve = require \events .EventEmitter
_   = require \underscore

module.exports = class extends Eve
  (vm, vg) ->
    vg.on \render ~>
      vg.$el.on \click ~>
        vg.svg.select \.cursor .remove!
        @emit \remove
        render nd._id if nd = find-nearby-node it.offsetX, it.offsetY

      function find-nearby-node x, y
        const RADIUS = 100px
        function is-near x0, x1, y0, y1 # rough but fast initial proximity test
          Math.abs(x1 - x0) < RADIUS and Math.abs(y1 - y0) < RADIUS
        function get-distance x0, x1, y0, y1
          ((x1 - x0) ^ 2) + ((y1 - y0) ^ 2) # for performance no need to Math.sqrt
        near-nodes = _.filter vg.d3f.nodes!, -> is-near it.x, x, it.y, y
        dists = _.map near-nodes, -> node:it, d:get-distance it.x, x, it.y, y
        min = _.min dists, -> it.d
        min.node if min.d < RADIUS ^ 2

    vm.on \render (id) ~>
      if id then vg.on \cooled ~> render id

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

    ~function render id
      n = vg.svg.select "g.node.id_#id"
      n.append \svg:path
        .attr \class \cursor
        .attr \d get-cursor-path!
      @emit \render id
