# Note the core graph is decoupled from these components.
# Event handlers fire in the same order these files are init'd (neat Backbone feature!).
# This is especially important for render handlers relying on svg's painters algo.
module.exports = (vm = v-map) ->
  vg = vm.v-graph

  (require \./layer/slit) vg
  (require \./edge-glyph).init vg
  (require \./layer) vg
  (require \./layer/bil/edge) vg
  (require \./layer/bil/node).init vg
  (require \./pin) vg
  (require \./region) vg
  cu = (new (require \./cursor) vg)
  (require \./animator) vg, cu
  (require \./anthill) vg, cu
