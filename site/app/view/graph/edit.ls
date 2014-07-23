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

    ..on \saved, (map, is-new) ->
      V.navbar.render!
      navigate "map/#{map.id}" if is-new

    ..on \serialized, ->
      save-is-default it.id
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

function disable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, true .addClass \disabled

function enable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, false .removeClass \disabled

function get-hive-graph-value
  JSON.parse M.Hive.Graph.get \value

function load-is-default id
  v = get-hive-graph-value! .default?id
  log v
  V.map-edit.$el.find \#is-default .prop \checked, v is id

function navigate
  R.navigate it, trigger:true

function save-is-default id
  $is-default = V.map-edit.$el.find \#is-default
  set-default-map if $is-default.prop \checked then id else void

function set-default-map id
  v = get-hive-graph-value!
  v.default = id:id
  M.Hive.Graph
    ..set \value, JSON.stringify v
    ..save { error:H.on-err, success: -> log 'saved default map-id' }

