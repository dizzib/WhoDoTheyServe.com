F = require \fs
_ = require \underscore
H = require \../../helper
W = require \../../../lib/when

H.insert-css F.readFileSync __dirname + \/edge.css

module.exports =
  data: (nodes, edges, map-when) ->
    map-when-int = if map-when then W.parse map-when, \max else W.get-int-today!

    function is-family
      a = it.source.family-name and b = it.target.family-name and a is b

    function is-out-of-range
      not (it.when.int.from <= map-when-int <= it.when.int.to)

    d3-edges = _.map edges, (edge) -> _.extend do
      edge
      source: _.find nodes, -> it._id is edge.a_node_id
      target: _.find nodes, -> it._id is edge.b_node_id

    for d3e in d3-edges
      arr = []
      arr.push \minor if is-out-of-range d3e
      arr.push \family if is-family d3e
      d3e.class = arr * ' '

    d3-edges

  init: (svg, d3f) ~>
    svg.append \svg:defs .selectAll \marker
      .data <[ end ]>
      .enter!append \svg:marker
        .attr \id          , String
        .attr \viewBox     , '0 -5 10 10'
        .attr \refX        , 20
        .attr \markerWidth , 10
        .attr \markerHeight, 10
        .attr \orient      , \auto
      .append \svg:path
        .attr \d, 'M0,-5L10,0L0,5'
    @lines = svg.selectAll \line
      .data d3f.links!
      .enter!append \svg:line
        .attr \class     , -> "edge #{it.class}".trim!
        .attr \marker-end, -> if it.a_is is \lt then 'url(#end)' else ''

  get-strength: ->
    x = if it.class is \minor then 1 else 20
    w = it.source.weight + it.target.weight
    x / w

  on-tick: ~>
    @lines
      .attr \x1, -> it.source.x
      .attr \y1, -> it.source.y
      .attr \x2, -> it.target.x
      .attr \y2, -> it.target.y
