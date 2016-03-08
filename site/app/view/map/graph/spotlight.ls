B = require \backbone
_ = require \underscore

module.exports = (vg, cursor) ->
  var edges-by-node-id

  cursor.on \remove ->
    vg.svg.selectAll \.lit .classed \lit false

  cursor.on \render (id) ->
    sel = (_.map edges-by-node-id[id], -> ".id_#{it.id}").join \,
    vg.svg.selectAll sel .classed \lit true if sel
    B.tracker.node-ids.push id

  vg.on \late-render ->
    edges-by-node-id := {}
    vg.map.get \entities .edges.each ->
      (edges-by-node-id[it.get \a_node_id] ||= []).push it
      (edges-by-node-id[it.get \b_node_id] ||= []).push it
