F  = require \fs
C  = require \../../collection
H  = require \../../helper
Hi = require \../../hive
R  = require \../../router
V  = require \../../view

H.insert-css F.readFileSync __dirname + \/edit.css

module.exports.init = ->
  V.map-edit
    ..on \destroyed, ->
      delete V.map.map
      V.navbar.render!
      navigate \session

    ..on \rendered, ->
      disable-buttons! # enabled when d3 has cooled
      render-dropdown!
      init-error-alert!
      load-is-default it.id
      @$el.find \legend .on \click, ~> @$el.find \form .toggleClass \collapsed

    ..on \saved, (map, is-new) ->
      save-is-default map.id if V.map-edit.$el.find \#is-default .prop \checked
      V.navbar.render!
      init-error-alert!
      navigate "map/#{map.id}" if is-new

    ..on \serialized, ->
      # save all selected nodes -- some may have been filtered out of the map in
      # which case they'll be saved without (x, y)
      nodes = (v = V.map).get-nodes-xy!
      sel-node-ids = V.map-nodes-sel.get-selected-ids!
      map-node-ids = _.map nodes, -> it._id
      for id in sel-node-ids then unless _.contains map-node-ids, id
        nodes.push _id:id # node is selected but filtered out of map
      it.set { nodes:nodes, 'size.x':v.get-size-x!, 'size.y':v.get-size-y! }

    ..show = ->
      init-error-alert!
      @$el.show!

  V.map-nodes-sel.on 'checkAll click uncheckAll', ->
    # checkAll also fires if all nodes are already selected and the dropdown is opened
    # even if the selection is unchanged, in which case bail
    return unless V.map.refresh-entities V.map-nodes-sel.get-selected-ids!
    V.map.render is-slow-to-cool:true
    V.map-toolbar.render! # reset checkboxes

  V.map
    ..on \render  , disable-buttons
    ..on \rendered, enable-buttons

  C.Nodes.on 'add remove', render-dropdown

# helpers

function disable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, true .addClass \disabled

function enable-buttons
  V.map-edit.$el.find \.btn .prop \disabled, false .removeClass \disabled

function init-error-alert
  # show errors on this form rather than in base view
  $ \.alert-error .removeClass \active
  V.map-edit.$el.find \.alert-error .addClass \active .hide!

function load-is-default id
  V.map-edit.$el.find \#is-default .prop \checked, id is (Hi.Map.get-prop \default)?id

function navigate
  R.navigate it, trigger:true

function render-dropdown
  return unless map = V.map.map # might not be initialised e.g. add node before edit map
  V.map-nodes-sel.render C.Nodes, \name, _.pluck (map.get \nodes), \_id

function save-is-default id
  Hi.Map
    ..set-prop \default, id:id
    ..save { error:H.on-err, success: -> log 'saved default map-id' }
