B  = require \backbone
C  = require \../../collection
Hv = require \../../model/hive .instance
V  = require \../../view

B.once \signin, -> # should only run once on first signin
  # multi-select can't be browserified 'cos it references an adjacent png
  yepnope.injectCss \/lib-3p/multiple-select.css

  V.map-edit
    ..on \destroyed, ->
      V.map.delete!

    ..on \rendered, ->
      disable-buttons! # enabled when d3 has cooled
      render-dropdown!
      init-error-alert!
      load-is-default it.id
      @$el.find \legend .on \click, ~> @$el.find \form .toggleClass \collapsed

    ..on \saved, (map, is-new) ->
      save-is-default map.id if V.map-edit.$el.find \#is-default .prop \checked
      init-error-alert!

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
    V.map-toolbar.reset!

  V.map
    ..on \pre-cool, disable-buttons
    ..on \cooled  , enable-buttons

  C.Nodes.on 'add remove', render-dropdown

  ## helpers

  function disable-buttons
    V.map-edit.$el.find \.btn .prop \disabled, true .addClass \disabled

  function enable-buttons
    V.map-edit.$el.find \.btn .prop \disabled, false .removeClass \disabled

  function init-error-alert
    # show errors on this form rather than in base view
    $ \.alert-error .removeClass \active
    V.map-edit.$el.find \.alert-error .addClass \active .hide!

  function load-is-default id
    V.map-edit.$el.find \#is-default .prop \checked, id is (Hv.Map.get-prop \default)?id

  function render-dropdown
    return unless map = V.map.map # might not be initialised e.g. add node before edit map
    V.map-nodes-sel.render C.Nodes, \name, _.pluck (map.get \nodes), \_id

  function save-is-default id
    Hv.Map
      ..set-prop \default, id:id
      ..save success: -> log 'saved default map-id'
