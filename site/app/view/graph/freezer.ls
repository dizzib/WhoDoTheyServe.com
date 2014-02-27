_ = require \underscore
N = require \./node
P = require \./persister
S = require \../../session

exports
  ..fix-unless-admin = (nodes) ->
    _.each nodes, -> it.fixed =
      (not S.is-signed-in-admin! and P.is-persisted!)
      or (S.is-signed-in-admin! and N.is-you it)
    nodes

  ..make-draggable-if-admin = (svg, d3-force) ->
    if S.is-signed-in-admin! then
      svg.selectAll \g.node .call d3-force.drag
