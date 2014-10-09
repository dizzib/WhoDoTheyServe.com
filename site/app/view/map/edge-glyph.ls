const ICON-GAP    = 1
const ICON-SIZE   = 16
const ICON-SPACE  = ICON-SIZE + ICON-GAP

module.exports = me =
  append: (edge) -> # called externally
    evs = _.filter me.evs, -> edge._id is it.get \entity_id
    dx  = - (ICON-SPACE * (evs.length - 1)) / 2
    dy  = ICON-SIZE / 2
    for ev, i in evs
      d3.select this
        .append \svg:a
          .attr \target     , \_blank
          .attr \xlink:href , -> ev.get \url
          .attr \xlink:title, -> edge.tip
          .append \text
            .attr \class, -> if ev.is-dead! then \dead else \live
            .attr \font-family, \FontAwesome
            .attr \x, dx + i * ICON-SPACE
            .attr \y, dy
            .text -> ev.get-glyph!unicode

  get-transform: -> # called externally
    x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
    y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
    "translate(#x,#y)"

  init: (svg, d3f, evs) ->
    me.evs = evs
    me.g = svg.selectAll \g.edge-glyphs
      .data d3f.links!
      .enter!append \svg:g
        .attr \class, \edge-glyphs
    me.g.each me.append

  on-tick: ->
    me.g.attr \transform me.get-transform
