_ = require \underscore
C = require \../../collection
V = require \../../view

module.exports =
  init: ->
    init-sel V.edge-a-node-sel, it.get \a_node_id
    init-sel V.edge-b-node-sel, it.get \b_node_id

    ($how = @$ \#how).typeahead source:_.uniq C.Edges.pluck \how
    auto-populate-how! if it.isNew!

    @$ \.btn-swap-ab .click ->
      a-id = (sel-a = V.edge-a-node-sel).get-selected-id!
      b-id = (sel-b = V.edge-b-node-sel).get-selected-id!
      sel-a.set-by-id b-id
      sel-b.set-by-id a-id

    function auto-populate-how
      a-id = V.edge-a-node-sel.get-selected-id!
      b-id = V.edge-b-node-sel.get-selected-id!
      return unless a-id and b-id
      top-hows = (get-top-hows a-id) ++ (get-top-hows b-id)
      top-how = (_.max top-hows, -> it.1).0
      # never clear, to avoid intermittent app test fail with sel.on \selected timing
      $how.val top-how if top-how?length

    function get-top-hows node-id
      edges = (C.Edges.where a_node_id:node-id) ++ (C.Edges.where b_node_id:node-id)
      _.pairs _.countBy edges, -> it.get \how

    function init-sel sel, default-id
      sel.render C.Nodes, \name, default-id
      sel.on \selected auto-populate-how
