F = require \fs
_ = require \underscore
I = require \../../lib-3p/insert-css
C = require \../../collection

I F.readFileSync __dirname + \/edge.css

exports
  ..data = (nodes) ->
    _.map C.Edges.models, (m) -> _.extend do
      m.toJSON-T!
      source  : _.find nodes, -> it._id is m.get \a_node_id
      target  : _.find nodes, -> it._id is m.get \b_node_id

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
        .attr \class, ->
          "edge #{it.class} #{if is-out-of-range it then \minor else ''}".trim!
        .attr \marker-end, ->
          if it.a_is is \lt then 'url(#end)' else ''

  ..get-strength = ->
      x = if is-out-of-range it then 1 else 20
      w = it.source.weight + it.target.weight
      x / w

  ..on-tick = ~>
    @lines
      .attr \x1, -> it.source.x
      .attr \y1, -> it.source.y
      .attr \x2, -> it.target.x
      .attr \y2, -> it.target.y

function is-out-of-range edge then
  const RANGE =
    year_from: 2011
    year_to  : 2013
  year_from = edge.year_from
  year_to   = edge.year_to or 9999
  return year_to < RANGE.year_from or RANGE.year_to < year_from
