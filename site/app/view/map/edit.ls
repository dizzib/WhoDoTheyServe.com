F  = require \fs
C  = require \../../collection
H  = require \../../helper
M  = require \../../model
R  = require \../../router
V  = require \../../view

H.insert-css F.readFileSync __dirname + \/edit.css

module.exports.init = ->
  V.map-edit
    ..on \destroyed, ->
      V.navbar.render!
      navigate \session

    ..on \rendered, ->
      disable-buttons! # enabled when d3 has cooled
      V.map-nodes-sel.render C.Nodes, \name, _.pluck (it.get \nodes), \_id
      load-is-default it.id
      @$el.find \legend .on \click, ~> @$el.find \.body .toggle!

    ..on \saved, (map, is-new) ->
      V.navbar.render!
      navigate "map/#{map.id}" if is-new

    ..on \serialized, ->
      save-is-default it.id if V.map-edit.$el.find \#is-default .prop \checked
      # save all selected nodes -- some may have been filtered out of the map in
      # which case they'll be saved without (x, y)
      nodes = (vg = V.map).get-nodes-xy!
      sel-node-ids = V.map-nodes-sel.get-selected-ids!
      map-node-ids = _.map nodes, -> it._id
      for id in sel-node-ids then unless _.contains map-node-ids, id
        nodes.push _id:id # node is selected but filtered out of map
      it.set { nodes:nodes, 'size-x':vg.get-size-x!, 'size-y':vg.get-size-y! }

  V.map-nodes-sel.on 'checkAll click uncheckAll', ->
    # checkAll also fires if all nodes are already selected and the dropdown is opened
    # even if the selection is unchanged, in which case bail
    return unless V.map.refresh-entities V.map-nodes-sel.get-selected-ids!
    V.map.render is-slow-to-cool:true
    V.map-toolbar.render! # reset checkboxes

  V.map
    ..on \render  , disable-buttons
    ..on \rendered, enable-buttons

# helpers

function disable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, true .addClass \disabled

function enable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, false .removeClass \disabled

function get-hive-map-value
  JSON.parse M.Hive.Map.get \value

function load-is-default id
  v = get-hive-map-value! .default?id
  V.map-edit.$el.find \#is-default .prop \checked, v is id

function navigate
  R.navigate it, trigger:true

function save-is-default id
  v = get-hive-map-value!
  v.default = id:id
  M.Hive.Map
    ..set \value, JSON.stringify v
    ..save { error:H.on-err, success: -> log 'saved default map-id' }
