_ = require \underscore
C = require \../collection
H = require \../helper
V = require \../view

exports
  ..init = ->
    V.edge-a-node-sel
      ..render C.Nodes, \name, it.get \a_node_id
      ..on \selected auto-populate-how
    V.edge-b-node-sel
      ..render C.Nodes, \name, it.get \b_node_id
      ..on \selected auto-populate-how
    $ \#how .typeahead source:_.uniq C.Edges.pluck \how
    # defer, otherwise won't focus in new edge for some reason
    _.defer -> $ '.editing input[type=text]:first' .focus!

    function auto-populate-how then
      a-id = V.edge-a-node-sel.get-selected-id!
      b-id = V.edge-b-node-sel.get-selected-id!
      return unless a-id and b-id
      top-hows = (get-top-hows a-id) ++ (get-top-hows b-id)
      $ \#how .attr \value, (_.max top-hows, -> it.1).0

    function get-top-hows node-id then
      edges = (C.Edges.where a_node_id:node-id) ++ (C.Edges.where b_node_id:node-id)
      _.pairs _.countBy edges, -> it.get \how
