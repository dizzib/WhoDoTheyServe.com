B = require \backbone
_ = require \underscore
R = require \../../../router

module.exports = (vm, cursor, v-find) ->

  var frag

  cursor.on \remove -> set-hash ''
  cursor.on \render -> set-hash "/node/#it"

  vm.on \render -> locate it
  vm.on \show   -> set-hash frag if frag  # restore hash

  v-find.on \select ->
    locate it
    vm.scroll-pos.restore!

  function locate id
    return unless id
    return unless n = _.findWhere vm.v-graph.d3f.nodes!, _id:id
    vm.scroll-pos.center n.x, n.y

  function set-hash
    B.history.stop!
    window.location.hash = "map/#{vm.map.id}#it"
    B.history.start silent:true
    frag := it
