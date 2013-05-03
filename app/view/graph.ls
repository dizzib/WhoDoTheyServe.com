B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
H = require \../helper

T = F.readFileSync __dirname + \/graph.html

module.exports = B.View.extend do
  render: ->
    @$el.html T .show!
    fd = new $jit.ForceDirected do
      injectInto: \fdvis
      height    : 600
      Navigation:
        enable      : yes
        panning     : 'avoid nodes'
        zooming     : 20
      Edge:
        overridable : yes
      Node:
        overridable : yes
        color       : \grey
      onCreateLabel: (el, node) ->
        $ \<a/> .text node.name .attr \href, "#/node-info/#{node.id}" .appendTo $ el
      Events:
        enable      : yes
        type        : \Native
        onDragMove: (node, eventInfo, e) ->
          pos = eventInfo.getPos!
          node.pos.setc(pos.x, pos.y)
          fd.plot!
        onTouchMove: (node, eventInfo, e) ->
          $jit.util.event.stop e
          @onDragMove node, eventInfo, e
      #iterations: 100
      #levelDistance: 100

    period-edges = C.Edges.find -> it.in_range 1900, 2013

    nodes = _.map C.Nodes.models, (n) ->
      edges = period-edges.find -> n.id is it.get \a_node_id
      adjs  = _.map edges.models, (l) ->
        return
          nodeFrom: a = l.get \a_node_id
          nodeTo  : b = l.get \b_node_id
          data:
            \$direction : [ a, b ]
            \$type      : if \lt is l.get \a_is then \arrow else \line
            #\$color     : \#0f0
      return
        id         : n.id
        name       : n.get \name
        adjacencies: adjs

    return unless nodes.length

    fd
      ..loadJSON nodes
      ..computeIncremental do
        iter:40
        onComplete: ->
          fd.animate do
            modes: [ \linear ]
            transition: $jit.Trans.Elastic.easeOut
            duration: 2500
