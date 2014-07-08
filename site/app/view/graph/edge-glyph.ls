C = require \../../collection
E = require \../evidence

const ICON-GAP    = 1
const ICON-SIZE   = 16
const ICON-SPACE  = ICON-SIZE + ICON-GAP

module.exports = me =
  init: (svg, d3-force) ~>
    @glyphs = svg.selectAll \g.edge-glyphs
      .data d3-force.links!
      .enter!append \svg:g
        .attr \class, \edge-glyphs
    @glyphs.each me.append

  append: (edge) ->
    evs = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
    dx  = - (ICON-SPACE * (evs.length - 1)) / 2
    dy  = ICON-SIZE / 2
    for ev, i in evs
      d3.select this
        .append \svg:a
          .attr \target     , \_blank
          .attr \xlink:href , -> ev.get \url
          .attr \xlink:title, -> edge.tip
          .append \text
            .attr \class, -> if E.is-dead ev.id then \dead else ''
            .attr \font-family, \FontAwesome
            .attr \x, dx + i * ICON-SPACE
            .attr \y, dy
            .text -> ev.get-glyph!unicode

  get-transform: ->
    x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
    y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
    "translate(#{x},#{y})"

  on-tick: ~>
    @glyphs.attr \transform, me.get-transform
