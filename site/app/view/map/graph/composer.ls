# Note the core graph is decoupled from these components.
# Event handlers fire in the same order these files are init'd (neat Backbone feature!).
# This is especially important for render handlers relying on svg's painters algo.
module.exports = (vm = v-map) ->
  vg = vm.v-graph

  (require \./node) vg
  (require \./edge) vg
  (require \./layer/slit) vg
  eg = (require \./edge-glyph) vg
  (require \./layer) vg
  bn = (require \./layer/bil/node) vg
  (require \./layer/bil/edge) vg, eg, bn
  (require \./pin) vg
  (require \./proximity) vg
  (require \./region) vg

  cu = (new (require \./cursor) vm, vg)
  (require \./animator) vg, cu
  (require \./anthill) vg, cu
  (require \./locator) vm, cu
  (require \./spotlight) vg, cu
