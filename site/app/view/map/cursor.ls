F = require \fs
_ = require \underscore
C = require \../../collection
H = require \../../helper

#H.insert-css F.readFileSync __dirname + \/cursor.css

module.exports =
  init: (map) ->
    svg = map.svg
    $svg = map.$el.find \svg

    map.$el.off \click, show-cursor # otherwise handler runs against old svg in closure
    map.$el.on  \click, show-cursor

    ## helpers

    function find-nearest-node x, y
      function get-distance x0, x1, y0, y1 then Math.sqrt(((x1 - x0) ^ 2) + ((y1 - y0) ^ 2))
      dists = _.map map.d3f.nodes!, ->
        it: it
        d : get-distance it.x, x, it.y, y
      (_.min dists, -> it.d).it

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

    function show-cursor
      [x, y] = [it.pageX - $svg.position!left, it.offsetY]
      id = (find-nearest-node x, y)._id
      n = svg.select "g.node.id_#id"
      svg.select \.cursor .remove!
      n.append \svg:path
        .attr \class, \cursor
        .attr \d, get-cursor-path!
