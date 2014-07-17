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
      # save all selected nodes -- some may have been filtered out of the d3 visualisation in
      # which case they won't have (x, y)
      node-ids = V.map-nodes-sel.get-selected-ids!
      d3-nodes = V.graph.get-nodes!
      it.set \nodes, _.map node-ids, (id) ->
        d3-node = _.find d3-nodes, -> it.id is id
        node = _id:id
        node <<< { x:d3-node.x, y:d3-node.y } if d3-node?
        node

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
