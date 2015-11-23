B  = require \backbone
_  = require \underscore
C  = require \../collection
M  = require \../model/map
Vm = require \./map

const NEW-MAP-KEY = -1

module.exports = B.View.extend do
  get-current: ->
    @map-views[@cur-key]?map

  is-current: (id) ->
    id is @get-current!?id

  initialize: ->
    ~function reset
      @cur-key   = null # current
      @map-views = {}   # cache by key
    reset!
    B.on 'signin signout' ~>
      for ,v of @map-views then v.remove!
      reset!

  render: (id, node-id, done) ->
    if _.isFunction node-id
      done = node-id
      node-id = null
    @cur-key = id or NEW-MAP-KEY
    return display vm.map if vm = @map-views[@cur-key]
    return display M.create! unless id

    return B.trigger \error "Unable to get map #id" unless map = C.Maps.get id
    loc = B.history.fragment
    map.fetch success: ->
      return unless B.history.fragment is loc # bail if user navigated away
      display it
      done!
    return false # async done

    ~function append-map-view
      @$el.append $map = (@$ \.map.template .clone!removeClass \template)
      vm = new Vm el:$map
      vm.v-edit
        ..on \destroyed ~>
          @map-views[it.id].remove!
          delete @map-views[it.id]
        ..on \saved (map, is-new) ~>
          if is-new # update key with new id
            @map-views[map.id] = @map-views[NEW-MAP-KEY]
            delete @map-views[NEW-MAP-KEY]
      @trigger \appended vm
      vm

    ~function display map
      unless vm = @map-views[@cur-key]
        vm = @map-views[@cur-key] = append-map-view!
        vm.render map, node-id
      vm.show!
      true # sync done
