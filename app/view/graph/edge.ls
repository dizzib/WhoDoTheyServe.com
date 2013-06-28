F = require \fs
_ = require \underscore
I = require \../../lib-3p/insert-css
C = require \../../collection
N = require \./node

I F.readFileSync __dirname + \/edge.css

exports
  ..data = (nodes) ->
    edges = _.reject C.Edges.toJSON-T!, is-exclude
    d3-edges = _.map edges, (edge) -> _.extend do
      edge
      source: _.find nodes, -> it._id is edge.a_node_id
      target: _.find nodes, -> it._id is edge.b_node_id
    return assign-classes(d3-edges) ++ get-ring-of-you nodes

    function assign-classes d3-edges then
      for edge in d3-edges
        edge.class = if is-out-of-range edge then \minor else ''
      return d3-edges

      function is-out-of-range edge then
        const RANGE =
          year_from: 2013
          year_to  : 2013
        year_from = edge.year_from
        year_to   = edge.year_to or 9999
        result = year_to < RANGE.year_from or RANGE.year_to < year_from
        return result or has-successor-governor edge

      # eg Mark Carney cannot govern both BoC and BoE simultaneously
      function has-successor-governor edge then
        successor = _.find edges, ->
          /govern/.test it.how and it.how is edge.how and
          it.year_from is edge.year_to and
          (it.a_node_id is edge.a_node_id or it.b_node_id is edge.b_node_id)

    function is-exclude edge then
      year_to = edge.year_to or 9999
      year_to < 1960

    function get-ring-of-you nodes then
      edges = []
      you-nodes = _.filter nodes, N.is-you
      last-node = _.last you-nodes
      for node in you-nodes
        edges.push do
          class : \you
          source: last-node
          target: node
        last-node = node
      return edges

  ..init = (svg, d3-force) ~>
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
      .data d3-force.links!
      .enter!append \svg:line
        .attr \class     , -> "edge #{it.class}".trim!
        .attr \marker-end, -> if it.a_is is \lt then 'url(#end)' else ''

  ..get-distance = ->
    if it.class is \you then 1800 else 100

  ..get-strength = ->
    x = if it.class is \minor then 1 else 20
    w = it.source.weight + it.target.weight
    x / w

  ..on-tick = ~>
    @lines
      .attr \x1, -> it.source.x
      .attr \y1, -> it.source.y
      .attr \x2, -> it.target.x
      .attr \y2, -> it.target.y
