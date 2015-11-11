_  = require \underscore
Hv = require \../../../model/hive .instance

module.exports = (vg) ->
  var nodes

  vg.on \render ->
    function is-you then /^YOU/.test it.name

    nodes := @svg.selectAll \g.node
      .data @d3f.nodes!
      .enter!append \svg:g
        .attr \class ->
          "node id_#{it._id} #{if is-you it then \you else ''}".trim!
    nodes
      ..append \svg:circle
        .attr \r -> 5 + it.weight + if is-you it then 10 else 0
      ..append \svg:a
        .attr \xlink:href -> "#/node/#{it._id}"
        .append \svg:text
          .attr \dy 4
          .attr \text-anchor \middle
          .text -> it.name

    return unless icons = Hv.Map.get-prop \icons

    const ICON-SIZE = 20
    for icon in icons
      g = @svg.select "g.id_#{icon.id}"
      if icon.glyph
        g.append \text
          .attr \class \fa
          .attr \font-family \FontAwesome
          .attr \font-size ICON-SIZE
          .attr \x - ICON-SIZE * 0.5
          .attr \y - ICON-SIZE * 0.75
          .text -> icon.glyph
      else if icon.image
        size = icon.size / \x
        g.append \svg:image
          .attr \xlink:href icon.image
          .attr \x      x = -size.0 / 2
          .attr \y      y = -size.1 - 12
          .attr \width  size.0
          .attr \height size.1
        if size.2
          g.append \svg:rect
            .attr \x      x - 1
            .attr \y      y - 1
            .attr \width  2 + parseInt size.0
            .attr \height 2 + parseInt size.1

  vg.on \tick ->
    nodes.attr \transform -> "translate(#{it.x},#{it.y})"
