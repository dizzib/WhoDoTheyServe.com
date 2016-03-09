_ = require \underscore

$w = $ w = window

module.exports = class
  (@v-graph) ->

  center: (x, y) ->
    @pos =
      x: x - w.innerWidth / 2
      y: y - w.innerHeight / 2 + 40px

  restore: ->
    ~function get-initial-scroll-pos
      return x:0 y:0 unless svg = @v-graph.svg # might be undefined e.g. new map
      # center map
      x: Math.max 0 (svg.attr(\width) - w.innerWidth) / 2
      y: Math.max 0 (svg.attr(\height) - w.innerHeight) / 2

    @pos ?= get-initial-scroll-pos!
    $w.scrollLeft @pos.x if @pos.x
    $w.scrollTop @pos.y if @pos.y

  save: ->
    @pos.x = $w.scrollLeft!
    @pos.y = $w.scrollTop!
    $w.scrollLeft 0
    $w.scrollTop 0
