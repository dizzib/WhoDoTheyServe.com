B  = require \backbone
C  = require \../../../collection
Hv = require \../../../model/hive .instance
V  = require \../../../view
Vs = require \../../../view-activity/select

B.once \signin -> # should only run once on first signin
  v  = V.map.view
  ve = v.tool.edit
  vg = v.graph

  C.Edges.on 'add remove' ->
    node-ids = ve.v-nodes-sel.get-selected-ids!
    refresh-map node-ids if do
      _.contains node-ids, it.get \a_node_id and _.contains node-ids, it.get \b_node_id
  C.Nodes
    ..on \add ->
      node-ids = render-dropdown(it.id if add2map = it?get \__add-to-map)
      refresh-map node-ids if add2map
    ..on \remove ->
      node-ids = render-dropdown!
      refresh-map node-ids if _.contains node-ids, it.id
  ve
    ..on \destroyed ->
      V.map.delete!
    ..on \rendered ->
      alert-success void
      init-dropdown!
      render-dropdown!
      init-error-alert!
      load-is-default it.id
    ..on \saved (map, is-new) ->
      save-is-default map.id if ve.$el.find \#is-default .prop \checked
      alert-success 'Successfully saved'
      init-error-alert!
    ..on \serialized ->
      # save all selected nodes -- some may have been filtered out of the map in
      # which case they'll be saved without (x, y)
      nodes = vg.get-nodes-xy!
      sel-node-ids = ve.v-nodes-sel.get-selected-ids!
      map-node-ids = _.map nodes, -> it._id
      for id in sel-node-ids then unless _.contains map-node-ids, id
        nodes.push _id:id # node is selected but filtered out of map
      it.set nodes:nodes, 'size.x':vg.get-size-x!, 'size.y':vg.get-size-y!
    ..show = ->
      alert-success void
      init-error-alert!
      @$el.show!
  vg
    ..on \pre-cool -> ve.$el.disable-buttons!
    ..on \cooled   -> ve.$el.enable-buttons!

  ## helpers

  function alert-success msg
    ve.$el.find \.alert-success .text msg .toggle msg?

  function init-dropdown
    opts = filter:true maxHeight:500 width:370
    ve.v-nodes-sel = new Vs.MultiSelectView el:(ve.$ \#nodes), opts:opts
      ..on 'checkAll click uncheckAll' ->
        node-ids = @get-selected-ids!
        # checkAll also fires if all nodes are already selected and the dropdown is opened
        # even if the selection is unchanged, in which case bail
        return if node-ids.length is (vg.map.get \nodes)?length
        refresh-map node-ids

  function init-error-alert
    # show errors on this form rather than in base view
    $ \.alert-error .removeClass \active
    ve.$el.find \.alert-error .addClass \active .hide!

  function load-is-default id
    ve.$el.find \#is-default .prop \checked id is (Hv.Map.get-prop \default)?id

  function render-dropdown add-node-id
    return unless ve.v-nodes-sel?
    node-ids = if vg.map then _.pluck (vg.map.get \nodes), \_id else []
    node-ids.push add-node-id if add-node-id
    ve.v-nodes-sel.render C.Nodes, \name, node-ids
    node-ids

  function refresh-map node-ids
    vg.refresh-entities node-ids .render is-slow-to-cool:true

  function save-is-default id
    Hv.Map
      ..set-prop \default id:id
      ..save success: -> log 'saved default map-id'
