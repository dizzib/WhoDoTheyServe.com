C = require \../../collection

const FA-FILETEXT = \\uf0f6
const FA-VIDEO    = \\uf03d
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
            .attr \font-family, \FontAwesome
            .attr \x, dx + i * ICON-SPACE
            .attr \y, dy
            .text -> if ev.toJSON-T!is-video then FA-VIDEO else FA-FILETEXT

  get-transform: ->
    x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
    y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
    "translate(#{x},#{y})"

  on-tick: ~>
    @glyphs.attr \transform, me.get-transform
