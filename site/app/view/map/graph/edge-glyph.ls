const ICON-GAP   = 1
const ICON-SIZE  = 16
const ICON-SPACE = ICON-SIZE + ICON-GAP

module.exports = (vg) ->
  var g

  vg.on \late-render ->
    g := @svg.selectAll \g.edge-glyphs
      .data @d3f.links!
      .enter!append \svg:g
        .attr \class -> "edge-glyphs id_#{it._id} #{it.class}"
    g.each me.append
    g.attr \transform me.get-transform
  vg.on \tick ->
    g?attr \transform me.get-transform

  me =
    append: (edge) ->
      return unless evs = vg.map.get \entities .evidences.where entity_id:edge._id
      dx = - (ICON-SPACE * (evs.length - 1)) / 2
      dy = ICON-SIZE / 2
      for ev, i in evs
        evj = ev.toJSON-T!
        d3.select this
          .append \svg:a
            .attr \target \_blank
            .attr \xlink:href  -> evj.href
            .attr \xlink:title -> edge.tip
            .append \text
              .attr \class -> if evj.is-bare then \bare-href else \safe-href
              .attr \font-family \fontello
              .attr \x dx + i * ICON-SPACE
              .attr \y dy
              .text -> evj.glyph.unicode
    get-transform: ->
      x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
      y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
      "translate(#x,#y)"
