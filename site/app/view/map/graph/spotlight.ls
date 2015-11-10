_ = require \underscore
C = require \../../../collection

module.exports = (vg, cursor) ->
  cursor.on \hide ->
    vg.svg.selectAll \.lit .classed \lit false

  cursor.on \show ->
    edges = (C.Edges.where a_node_id:it._id) ++ C.Edges.where b_node_id:it._id
    sel = (_.map edges, -> ".id_#{it.id}").join \,
    vg.svg.selectAll sel .classed \lit true if sel
