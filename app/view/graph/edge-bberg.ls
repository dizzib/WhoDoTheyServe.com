F = require \fs
_ = require \underscore
C = require \../../collection
I = require \../../lib-3p/insert-css
N = require \./node-bberg

I F.readFileSync __dirname + \/edge-bberg.css

exports
  ..filter-out = (edges) ->
    @groups = _.groupBy edges, ->
      if N.is-bberg-conference it.source
      or N.is-bberg-conference it.target then \yes else \no
    @groups.no

  ..render = (svg, d3-force) ->
    return unless @groups.yes.length
    @g = svg.append \svg:g
    node-bac = _.find d3-force.nodes!, -> it.name is 'Bilderberg Annual Conference'
    for edge in @groups.yes
      [src, tar] = [edge.source, edge.target]
      @g.append \svg:line
        .attr \x1, if N.is-bberg-conference src then node-bac.x else src.x
        .attr \y1, if N.is-bberg-conference src then node-bac.y else src.y
        .attr \x2, if N.is-bberg-conference tar then node-bac.x else tar.x
        .attr \y2, if N.is-bberg-conference tar then node-bac.y else tar.y
        .attr \class, 'edge bberg'

  ..render-clear = (svg) -> @g.remove!
