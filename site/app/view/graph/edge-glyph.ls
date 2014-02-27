C = require \../../collection

const ICON-SIZE = 16

exports
  ..init = (svg, d3-force) ~>
    @glyphs = svg.selectAll \g.edge-glyphs
      .data d3-force.links!
      .enter!append \svg:g
        .attr \class, \edge-glyphs
    @glyphs.each exports.append

  ..append = (edge) ->
    evs = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
    dx = - ((ICON-SIZE + 1) * (evs.length - 1)) / 2
    for ev, i in evs
      d3.select this
        .append \svg:a
          .attr \target     , \_blank
          .attr \xlink:href , -> ev.get \url
          .attr \xlink:title, -> edge.tip
          .append \svg:image
            .attr \xlink:href, "/asset/#{get-icon ev}.svg"
            .attr \x         , dx + i * (ICON-SIZE + 1)
            .attr \width     , ICON-SIZE
            .attr \height    , ICON-SIZE

    function get-icon ev then if ev.toJSON-T!is-video then \video else \camera

  ..get-transform = ->
    x = it.source.x + (it.target.x - it.source.x - ICON-SIZE) / 2
    y = it.source.y + (it.target.y - it.source.y - ICON-SIZE) / 2
    "translate(#{x},#{y})"

  ..on-tick = ~>
    @glyphs.attr \transform, exports.get-transform
