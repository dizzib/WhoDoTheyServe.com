F = require \fs
_ = require \underscore
C = require \../../../collection
H = require \../../../helper
I = require \../../../lib-3p/insert-css
N = require \./node

I F.readFileSync __dirname + \/edge.css

exports
  ..filter-out = (edges) ->
    groups = _.groupBy edges, ->
      if it.how is \member
      and (N.is-cfr it.source or N.is-cfr it.target)
      then \yes else \no
    @edges = groups.yes
    return groups.no

  ..render = (g, d3-force) ->
    return unless @edges.length
    cfr = _.find d3-force.nodes!, N.is-cfr
    @g = g.append \svg:g
    for edge in @edges
      [src, tar] = [edge.source, edge.target]
      @g.append \svg:line
        .attr \x1, if N.is-cfr src then cfr.x else src.x
        .attr \y1, if N.is-cfr src then cfr.y else src.y
        .attr \x2, if N.is-cfr tar then cfr.x else tar.x
        .attr \y2, if N.is-cfr tar then cfr.y else tar.y
        .attr \class, "edge cfr"

  ..render-clear = ->
    @g.remove!
