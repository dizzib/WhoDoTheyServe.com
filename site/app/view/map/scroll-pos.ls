Br = require \../../lib/browser

$w = $ w = window

module.exports = class
  (@v-graph) ->

  center: (x, y) ->
    @pos =
      x: x - w.innerWidth / 2
      y: y - w.innerHeight / 2 + 40px

  restore: ->
    @pos ?= unless svg = @v-graph.svg then x:0 y:0 else # new map has no svg
      # center map if first time in
      x: Math.max 0 (svg.attr(\width) - w.innerWidth) / 2
      y: Math.max 0 (svg.attr(\height) - w.innerHeight) / 2
    #log \restore @pos, @name = @v-graph.map.get \name
    Br.scroll-to @pos

  save: ->
    @pos.x = $w.scrollLeft!
    @pos.y = $w.scrollTop!
    #log \save @pos, @name
