# Note the core graph is decoupled from these components.
# Event handlers fire in the same order these files are init'd (neat Backbone feature!).
# This is especially important for render handlers relying on svg's painters algo.
module.exports = (vm = v-map) ->
  (require \../overlay/slit) vm.v-graph
  (require \../edge-glyph).init vm.v-graph
  (require \../overlay) vm.v-graph, vm.v-layers
  (require \../overlay/bil/edge) vm.v-graph, vm.v-layers
  (require \../overlay/bil/node).init vm.v-graph
  (require \../pin) vm.v-graph
  (require \../region) vm.v-graph
  (Cur = require \../cursor).init vm.v-graph
  (require \../animator) vm.v-graph, Cur
  (require \../anthill) vm.v-graph, Cur
