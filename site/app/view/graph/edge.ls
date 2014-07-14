F = require \fs
_ = require \underscore
H = require \../../helper
N = require \./node

H.insert-css F.readFileSync __dirname + \/edge.css

module.exports =
  data: (entities) ->
    d3-edges = _.map entities.edges, (edge) -> _.extend do
      edge
      source: _.find entities.nodes, -> it._id is edge.a_node_id
      target: _.find entities.nodes, -> it._id is edge.b_node_id
    return assign-classes d3-edges

    function assign-classes d3-edges then
      for d3-edge in d3-edges
        cls = []
        if is-out-of-range d3-edge then cls.push \minor
        if is-family       d3-edge then cls.push \family
        d3-edge.class = cls * ' '
      return d3-edges

      function is-family d3-edge then
        return false unless family-name-a = d3-edge.source.family-name
        return false unless family-name-b = d3-edge.target.family-name
        return family-name-a is family-name-b

      function is-out-of-range d3-edge then
        const RANGE =
          year_from: 2013
          year_to  : 2013
        yf = d3-edge.year_from or d3-edge.year or 0
        yt = d3-edge.year_to   or d3-edge.year or 9999
        result = yt < RANGE.year_from or RANGE.year_to < yf
        return result or has-successor-governor d3-edge

      # eg Mark Carney cannot govern both BoC and BoE simultaneously
      function has-successor-governor d3-edge then
        successor = _.find entities.edges, ->
          /governor/.test it.how and it.how is d3-edge.how and
          it.year_from is d3-edge.year_to and
          (it.a_node_id is d3-edge.a_node_id or it.b_node_id is d3-edge.b_node_id)

  init: (svg, d3-force) ~>
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
