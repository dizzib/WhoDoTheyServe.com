F = require \fs
_ = require \underscore
C = require \../../collection
H = require \../../helper
I = require \../../lib-3p/insert-css
N = require \./node-bberg

I F.readFileSync __dirname + \/edge-bberg.css

exports
  ..filter-out = (edges) ->
    @steer-edges = _.groupBy edges, ->
      if it.how is \member
      and (N.is-steering it.source or N.is-steering it.target)
      then \yes else \no
    steer-nodes = _.map @steer-edges.yes, ->
      if N.is-steering it.source then it.target else it.source
    @attend-edges = _.groupBy @steer-edges.no, ->
      if (N.is-conference-yyyy it.source or N.is-conference-yyyy it.target) then
        s = _.find steer-nodes, (x) -> x._id in [it.source._id, it.target._id]
        if !!s then \discard else \yes
      else \no
    return @attend-edges.no

  ..render-attend = (svg, d3-force) ->
    @g-attend = render svg, d3-force, @attend-edges.yes,
      N.is-annual-conference, N.is-conference-yyyy, \bberg-attend

  ..render-steer = (svg, d3-force) ->
    @g-steer = render svg, d3-force, @steer-edges.yes,
      N.is-steering, N.is-steering, \bberg-steer

  ..render-clear = ->
    @g-attend.remove!
    @g-steer.remove!

function render svg, d3-force, edges, fn-get-hub, fn-is-hub, css-class then
  return unless edges.length
  g = svg.append \svg:g
  hub = _.find d3-force.nodes!, fn-get-hub
  for edge in edges
    [src, tar] = [edge.source, edge.target]
    g.append \svg:line
      .attr \x1, if fn-is-hub src then hub.x else src.x
      .attr \y1, if fn-is-hub src then hub.y else src.y
      .attr \x2, if fn-is-hub tar then hub.x else tar.x
      .attr \y2, if fn-is-hub tar then hub.y else tar.y
      .attr \class, "edge #{css-class}"
  return g
