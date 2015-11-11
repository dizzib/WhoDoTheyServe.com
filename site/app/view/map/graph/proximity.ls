const THRESHOLD = 200px ^ 2

module.exports = (vg) ->
  vg.on \cooled ->
    @svg.selectAll \.out-of-date .classed \near ->
      dx = it.source.x - it.target.x
      dy = it.source.y - it.target.y
      dx ^ 2 + dy ^ 2 < THRESHOLD

  vg.on \pre-cool ->
    @svg?selectAll \.near .classed \near false
