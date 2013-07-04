_ = require \underscore
S = require \../../session

exports
  ..fix-unless-admin = (nodes) ->
    unless S.is-signed-in-admin! then
      _.each nodes, -> it.fixed = true
    nodes

  ..make-draggable-if-admin = (svg, graph) ->
    if S.is-signed-in-admin! then
      svg.selectAll \g.node .call graph.drag
