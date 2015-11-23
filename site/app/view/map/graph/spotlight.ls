_ = require \underscore
C = require \../../../collection

module.exports = (vg, cursor) ->
  cursor.on \remove ->
    vg.svg.selectAll \.lit .classed \lit false

  cursor.on \render (id) ->
    edges = (C.Edges.where a_node_id:id) ++ C.Edges.where b_node_id:id
    sel = (_.map edges, -> ".id_#{it.id}").join \,
    vg.svg.selectAll sel .classed \lit true if sel
