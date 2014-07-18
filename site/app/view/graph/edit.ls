F = require \fs
C = require \../../collection
H = require \../../helper
R = require \../../router
V = require \../../view

H.insert-css F.readFileSync __dirname + \/edit.css

module.exports.init = ->
  V.map-edit
    ..on \destroyed, ->
      V.navbar.render!
      navigate \session

    ..on \rendered, ->
      disable-buttons! # enabled when d3 has cooled
      V.map-nodes-sel.render C.Nodes, \name, _.pluck (it.get \nodes), \_id

    ..on \saved, (map, is-new) ->
      V.navbar.render!
      navigate "map/#{map.id}" if is-new

    ..on \serialized, ->
      # save all selected nodes -- some may have been filtered out of the map in
      # which case they'll be saved without (x, y)
      nodes = (vg = V.graph).get-nodes-xy!
      sel-node-ids = V.map-nodes-sel.get-selected-ids!
      map-node-ids = _.map nodes, -> it._id
      for id in sel-node-ids then unless _.contains map-node-ids, id
        nodes.push _id:id # node is selected but filtered out of map
      it.set { nodes:nodes, 'size-x':vg.get-size-x!, 'size-y':vg.get-size-y! }

  V.map-nodes-sel.on 'checkAll click uncheckAll', ->
    # checkAll also fires if all nodes are already selected and the dropdown is opened
    # even if the selection is unchanged, in which case bail
    return unless V.graph.refresh-entities V.map-nodes-sel.get-selected-ids!
    V.graph.render is-slow-to-cool:true

  V.graph
    ..on \render  , disable-buttons
    ..on \rendered, enable-buttons

# helpers

function navigate then R.navigate it, trigger:true

function disable-buttons then V.map-edit.$el.find \.btn .prop \disabled, true .addClass \disabled

function enable-buttons then V.map-edit.$el.find \.btn .prop \disabled, false .removeClass \disabled
