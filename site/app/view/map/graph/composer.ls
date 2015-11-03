# Note the core graph is decoupled from these components.
# Event handlers fire in the same order these files are init'd (neat Backbone feature!).
# This is especially important for render handlers relying on svg's painters algo.
module.exports = (vm = v-map) ->
  vg = vm.v-graph
  vl = vm.v-layers

  (require \./overlay/slit) vg
  (require \./edge-glyph).init vg
  (require \./overlay) vg, vl
  (require \./overlay/bil/edge) vg, vl
  (require \./overlay/bil/node).init vg
  (require \./pin) vg
  (require \./region) vg
  cu = (new (require \./cursor) vg)
  (require \./animator) vg, cu
  (require \./anthill) vg, cu
