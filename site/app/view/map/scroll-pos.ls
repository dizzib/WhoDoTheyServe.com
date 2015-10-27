_ = require \underscore

$w = $ window

module.exports = class
  (@v-graph) ->

  delete: ->
    delete @pos

  restore: ->
    ~function get-initial-scroll-pos
      return x:0 y:0 unless svg = @v-graph.svg # might be undefined e.g. new map
      # center map
      x: Math.max 0 (svg.attr(\width) - $w.width!) / 2
      y: Math.max 0 (svg.attr(\height) - $w.height!) / 2

    @pos ?= get-initial-scroll-pos!
    _.defer ~>
      $w.scrollLeft @pos.x if @pos.x
      $w.scrollTop @pos.y if @pos.y

  save: ->
    @pos.x = $w.scrollLeft!
    @pos.y = $w.scrollTop!
