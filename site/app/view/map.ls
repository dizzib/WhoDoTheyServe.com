B  = require \backbone
F  = require \fs # browserified
_  = require \underscore
C  = require \../collection
S  = require \../session
D  = require \../view-handler/directive
V  = require \../view
Ve = require \../view-activity/edit
Vr = require \../view-activity/read
Gc = require \./map/graph/composer
Sp = require \./map/scroll-pos
T  = require \./map/tool
Te = require \./map/tool/edit

M-Map    = require \../model/map
V-Graph  = require \./map/graph
V-Layers = require \./map/tool/layers

T-Edit = F.readFileSync __dirname + \/map/tool/edit.html
T-Info = F.readFileSync __dirname + \/map/tool/info.html
T-Meta = F.readFileSync __dirname + \/meta.html

module.exports = B.View.extend do
  delete: ->
    delete @map
    @trigger \deleted

  initialize: ->
    @$el.html F.readFileSync __dirname + \/map.html

    @v-graph  = new V-Graph el:\.map>.graph
    @v-meta   = new Vr.InfoView el:\.map>.meta template:T-Meta
    @v-edit   = new Ve.EditView el:\.tool.edit template:T-Edit
    @v-info   = new Vr.InfoView el:\.tool.info template:T-Info
    @v-layers = new V-Layers el:\.tool.layers

    @v-edit.on \destroyed ~> @delete!
    @v-info.on \rendered -> @$el.hide! unless it.get \description
    B.on 'signin signout' ~>
      @delete!
      @$el.set-access S

    Gc @
    T @
    Te @v-edit, @v-graph

    @scroll-pos = new Sp @v-graph

  render: (id) ->
    ~function show m
      return unless B.history.fragment is loc # bail if user navigated away
      @v-graph.map = @map
      if is-sel-changed
        @v-graph.render!
        @v-layers.reset!
        V.navbar.render!
        @scroll-pos.delete!
      @v-graph.show!
      @v-meta.render @map, D.meta
      @v-layers.render!
      @v-info.render @map, D.map
      if @map.get-is-editable!
        if is-init-new or is-sel-changed
          @v-edit.render @map, C.Maps, fetch:no directive:D.map-edit
        @v-edit.show!
      @$el.show!.on \hide ~>
        @$el.off \hide
        @scroll-pos.save!
      @scroll-pos.restore!
      done!

    done = arguments[*-1]
    loc = B.history.fragment
    is-init-new = not id and (not @map or not @map.isNew!)
    is-sel-changed = id isnt (@map?id or null)
    return show @map = M-Map.create! if is-init-new
    return show @map unless is-sel-changed
    return B.trigger \error "Unable to get map #id" unless @map = C.Maps.get id
    @map.fetch success:show
    false # async done
