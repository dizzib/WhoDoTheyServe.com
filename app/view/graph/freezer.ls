_ = require \underscore
N = require \./node
S = require \../../session

exports
  ..fix-unless-admin = (nodes) ->
    _.each nodes, -> it.fixed = not S.is-signed-in-admin! or N.is-you it
    nodes

  ..make-draggable-if-admin = (svg, d3-force) ->
    if S.is-signed-in-admin! then
      svg.selectAll \g.node .call d3-force.drag
