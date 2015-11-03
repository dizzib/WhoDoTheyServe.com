B  = require \backbone
F  = require \fs # browserified
C  = require \../collection
D  = require \../view-handler/directive
Ve = require \../view-activity/edit
Vr = require \../view-activity/read
Gc = require \./map/graph/composer
Sp = require \./map/scroll-pos
T  = require \./map/tool
Te = require \./map/tool/edit

V-Graph  = require \./map/graph
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
    @v-layers = new V-Layers el:@$ \.layers

    @v-info.on \rendered -> @$el.hide! unless it.get \description

    Gc @
    T @
    Te @v-edit, @v-graph

    @scroll-pos = new Sp @v-graph

  render: (@map) -> # @map for external ref
    @v-graph.map = @map
    @v-graph.render!
    @v-layers.render!
    @v-info.render @map, D.map
    @v-meta.render @map, D.meta
    @v-edit.render @map, C.Maps, fetch:no directive:D.map-edit if @map.get-is-editable!

  show: ->
    @$el.show! .on \hide ~>
      @$el.off \hide
      @scroll-pos.save!
    @v-graph.justify!
    @scroll-pos.restore!
