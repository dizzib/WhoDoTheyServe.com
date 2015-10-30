B  = require \backbone
C  = require \../collection
M  = require \../model/map
S  = require \../session
Vm = require \./map

module.exports = B.View.extend do
  clear: ->
    delete @v-map.map
    @trigger \cleared

  get-current: ->
    @v-map.map

  is-current: (id) ->
    id is @get-current!?id

  initialize: ->
    @$el.append $map = (@$ \.map.template .clone!removeClass \template)
    @v-map = vm = new Vm el:$map
    vm.v-edit
      ..on \destroyed ~>
        @clear!
        @trigger \deleted
      ..on \saved ~>
        @trigger \saved ...&
    B.on 'signin signout' ~>
      @clear!
      @$el.set-access S

  render: (id) ->
    done = arguments[*-1]
    loc = B.history.fragment
    m = @v-map.map

    is-init-new = not id and (not m or not m.isNew!)
    is-sel-changed = id isnt (m?id or null)

    return display M.create! if is-init-new
    return display m unless is-sel-changed
    return B.trigger \error "Unable to get map #id" unless map = C.Maps.get id
    map.fetch success:display
    false # async done

    ~function display map
      return unless B.history.fragment is loc # bail if user navigated away
      @v-map.render map if is-sel-changed or is-init-new
      @v-map.show!
      @trigger \rendered
      done!
