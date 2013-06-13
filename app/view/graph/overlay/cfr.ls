E = require \./cfr/edge
N = require \./cfr/node
V = require \../../../view

exports
  ..init = (svg, @f) ~>
    @g = svg.append \svg:g .attr \class, \cfr

    N.init!

    V.graph-toolbar.on \toggle-cfr, ~>
      @g.attr \display, if it then '' else \none

  ..filter-edges = ->
    E.filter it

  ..filter-nodes = ->
    return it

  ..render = ~>
    E.render @g, @f

  ..render-clear = ->
    E.render-clear!
