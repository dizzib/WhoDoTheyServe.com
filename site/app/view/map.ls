B  = require \backbone
F  = require \fs # browserified
_  = require \underscore
C  = require \../collection
S  = require \../session
D  = require \../view-handler/directive
V  = require \../view
Ve = require \../view-activity/edit
Vr = require \../view-activity/read
T  = require \./map/tool

M-Map    = require \../model/map
V-Graph  = require \./map/graph
V-Edit   = require \./map/tool/edit
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
    @view =
      graph: new V-Graph el:\.map>.graph
      meta: new Vr.InfoView el:\.map>.meta template:T-Meta
      tool:
        edit  : new Ve.EditView el:\.tool.edit template:T-Edit
        info  : new Vr.InfoView el:\.tool.info template:T-Info
        layers: new V-Layers el:\.tool.layers
    B.on 'signin signout' ~>
      @delete!
      @$el.set-access S
    T.init @
    @view.tool.info.on \rendered -> @$el.hide! unless it.get \description

  render: (id) ->
    ~function show m
      return unless B.history.fragment is loc # bail if user navigated away
      @$el.show!
      @view.graph.map = @map
      if is-sel-changed
        @view.graph.render!
        @view.tool.layers.reset!
        V.navbar.render!
      @view
        ..graph.show!
        ..meta.render @map, D.meta
        ..tool
          ..layers.render!
          ..info.render @map, D.map
      if @map.get-is-editable!
        if is-init-new or is-sel-changed
          @view.tool.edit.render @map, C.Maps, fetch:no directive:D.map-edit
        @view.tool.edit.show!
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
