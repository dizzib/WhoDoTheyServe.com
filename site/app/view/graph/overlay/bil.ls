E = require \./bil/edge
N = require \./bil/node
V = require \../../../view

module.exports =
  init: (svg, @f) ~>
    @ga = svg.append \svg:g .attr \class, \bil-attend
    @gs = svg.append \svg:g .attr \class, \bil-steer

    N.init svg

    add-handler @ga, \toggle-bil-attend
    add-handler @gs, \toggle-bil-steer

    function add-handler g, event then
      V.graph-toolbar.on event, -> g.attr \display, if it then '' else \none

  filter-edges: ->
    E.filter it

  filter-nodes: ->
    N.filter it

  render: ~>
    E.render-attend @ga, @f
    E.render-steer  @gs, @f

  render-clear: ->
    E.render-clear!
