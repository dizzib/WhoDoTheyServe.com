F = require \fs
_ = require \underscore
C = require \../../../../collection
H = require \../../../../helper
E = require \../../edge-glyph
N = require \./node

H.insert-css F.readFileSync __dirname + \/edge.css

exports
  ..filter = (edges) ->
    function is-conference-yyyy then
      N.is-conference-yyyy it.source or N.is-conference-yyyy it.target
    function is-steering then
      it.how is \member and (N.is-steering it.source or N.is-steering it.target)
    @edges-attend = _.filter edges, is-conference-yyyy
    @edges-steer  = _.filter edges, is-steering
    @nodes-steer  = _.map @edges-steer, ->
      if N.is-steering it.source then it.target else it.source
    _.difference edges, @edges-attend, @edges-steer

  ..render-attend = (g, d3-force) ->
    return unless @edges-attend
    edges = _.reject @edges-attend, (edge) ~>
      !!_.find @nodes-steer, -> it._id in [edge.source._id, edge.target._id]
    @g-attend = render g, d3-force, edges,
      N.is-annual-conference, N.is-conference-yyyy, \bil-attend

  ..render-steer = (g, d3-force) ->
    return unless edges = @edges-steer
    @g-steer = render g, d3-force, edges, N.is-steering, N.is-steering, \bil-steer
    glyphs = @g-steer.selectAll \g.edge-glyphs
      .data edges
      .enter!append \svg:g
        .attr \class, \edge-glyphs
    glyphs.each E.append
    glyphs.attr \transform E.get-transform

  ..render-clear = ->
    @g-attend?remove!
    @g-steer?remove!

function render g, d3-force, edges, fn-get-hub, fn-is-hub, css-class then
  hub = _.find d3-force.nodes!, fn-get-hub
  g-child = g.append \svg:g
  for edge in edges
    [src, tar] = [edge.source, edge.target]
    g-child.append \svg:line
      .attr \x1, if fn-is-hub src then hub.x else src.x
      .attr \y1, if fn-is-hub src then hub.y else src.y
      .attr \x2, if fn-is-hub tar then hub.x else tar.x
      .attr \y2, if fn-is-hub tar then hub.y else tar.y
      .attr \class, "edge #{css-class}"
  return g-child
