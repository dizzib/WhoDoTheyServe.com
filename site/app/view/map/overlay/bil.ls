V = require \../../../view
E = require \./bil/edge
N = require \./bil/node

var ga, gs

V.map
  ..on \cooled, ->
    E.render-attend ga, @d3f
    E.render-steer  gs, @d3f

  ..on \pre-cool, ->
    E.render-clear!

  ..on \pre-render, (ents) ->
    ents.edges = E.filter ents.edges
    ents.nodes = N.filter ents.nodes

  ..on \render ->
    function add-handler g, event
      V.map-toolbar.on event, -> g.attr \display, if it then '' else \none

    ga := @svg.append \svg:g .attr \class, \bil-attend
    gs := @svg.append \svg:g .attr \class, \bil-steer

    N.render @svg, E.edges-attend
    add-handler ga, \toggle-bil-attend
    add-handler gs, \toggle-bil-steer
