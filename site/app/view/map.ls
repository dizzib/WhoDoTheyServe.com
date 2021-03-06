B  = require \backbone
F  = require \fs # browserified
_  = require \underscore
C  = require \../collection
D  = require \../view-handler/directive
Ve = require \../view-activity/edit
Vr = require \../view-activity/read
Vs = require \../view-handler/ui/spinner
Gc = require \./map/graph/composer
Sp = require \./map/scroll-pos
T  = require \./map/tool
Te = require \./map/tool/edit

V-Graph  = require \./map/graph
V-Find   = require \./map/tool/find
V-Layers = require \./map/tool/layers

T-Edit = F.readFileSync __dirname + \/map/tool/edit.html
T-Info = F.readFileSync __dirname + \/map/tool/info.html
T-Meta = F.readFileSync __dirname + \/meta.html

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/map.html

    @v-graph  = new V-Graph el:@$ \.graph
    @v-meta   = new Vr.InfoView el:@$(\.meta), template:T-Meta
    @v-edit   = new Ve.EditView el:@$(\.edit), template:T-Edit
    @v-info   = new Vr.InfoView el:@$(\.info), template:T-Info
    @v-find   = new V-Find el:@$ \.find
    @v-layers = new V-Layers el:@$ \.layers

    @v-info.on \rendered -> @$el.toggle (it.get \description)?length > 0

    Gc @
    T @
    Te @v-edit, @v-graph

    @scroll-pos = new Sp @v-graph

  render: (@map, node-id) -> # @map for external ref
    Vs.set @$el
    (vg = @v-graph).map = @map
    vg.once \render-complete ~>
      <~ _.defer # allow completed map to display
      @v-find.render vg
      @v-layers.render vg
      @v-info.render @map, D.map
      @v-meta.render @map, D.meta
      @v-edit.render @map, C.Maps, fetch:no directive:D.map-edit if @map.get-is-editable!
      @map.globalise-entities! # do this expensive step last, for performance
      Vs.unset @$el
    vg.render!
    if not node-id and rxs = @map.get \node_default_rx
      try
        rx = new RegExp rxs
        node-id = (_.sample _.filter vg.d3f.nodes!, -> rx.test it.name)?_id
      catch ex then log ex
    @trigger \render node-id

  show: ->
    B.once \before-pre-route ~> @scroll-pos.save!
    @$el.show!
    @v-graph.justify!
    @scroll-pos.restore!
    @trigger \show
