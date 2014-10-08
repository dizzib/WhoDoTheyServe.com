_ = require \underscore
C = require \../../collection
H = require \../../helper
V = require \../../view

module.exports =
  init: ->
    init-sel V.edge-a-node-sel, it.get \a_node_id
    init-sel V.edge-b-node-sel, it.get \b_node_id

    $ \#how .typeahead source:_.uniq C.Edges.pluck \how

    # defer, otherwise won't focus in new edge for some reason
    _.defer -> $ '.editing input[type=text]:first' .focus!

    function auto-populate-how
      a-id = V.edge-a-node-sel.get-selected-id!
      b-id = V.edge-b-node-sel.get-selected-id!
      return unless a-id and b-id
      top-hows = (get-top-hows a-id) ++ (get-top-hows b-id)
      $ \#how .attr \value, (_.max top-hows, -> it.1).0

    function get-top-hows node-id
      edges = (C.Edges.where a_node_id:node-id) ++ (C.Edges.where b_node_id:node-id)
      _.pairs _.countBy edges, -> it.get \how

    function init-sel sel, default-id
      sel.render C.Nodes, \name, default-id
      sel.on \selected auto-populate-how
