F = require \fs
_ = require \underscore
H = require \../../helper
W = require \../../../lib/when

H.insert-css F.readFileSync __dirname + \/edge.css

module.exports =
  data: (nodes, edges, map-when) ->
    map-when-int = if map-when then W.parse map-when, \max else W.get-int-today!
    function is-in-range then W.is-in-range map-when-int, it.int

    # Choose the single edge to render for node-pairs having chronological edges
    node-pairs = {}
    reject-ids = []
    for e in edges
      [id0, id1] = [e.a_node_id, e.b_node_id]
      key = if id0 < id1 then "#id0,#id1" else "#id1,#id0" # treate A-B and B-A identically
      (node-pairs[key] ?= []).push e
    for k, v of node-pairs when v.length > 1
      p = _.partition v, -> is-in-range it.when-obj
      if p.0.length is 1 then reject-ids ++= _.pluck p.1, \_id else
        reject-ids ++= _.pluck v[0 til -1], \_id # all out of range, so just use the last one
    edges = _.reject edges, -> it._id in reject-ids

    d3es = _.map edges, (edge) -> _.extend do
      edge
      source: _.find nodes, -> it._id is edge.a_node_id
      target: _.find nodes, -> it._id is edge.b_node_id

    for d3e in d3es
      arr = []
      arr.push \minor if not is-in-range d3e.when-obj
      arr.push \family if a = d3e.source.family-name and b = d3e.target.family-name and a is b
      d3e.class = arr * ' '
    d3es

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
