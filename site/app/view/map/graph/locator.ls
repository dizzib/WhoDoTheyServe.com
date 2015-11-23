B = require \backbone
_ = require \underscore
R = require \../../../router

module.exports = (vm, cursor) ->

  cursor.on \remove -> set-hash ''
  cursor.on \render -> set-hash "/node/#it"

  vm.on \render (id) ->
    return unless id
    return unless n = _.findWhere vm.v-graph.d3f.nodes!, _id:id
    vm.scroll-pos.center n.x, n.y

function set-hash
  B.history.stop!
  l = window.location
  l.replace l.href.replace(/\/node\/.*$/ '') + it
  B.history.start silent:true
