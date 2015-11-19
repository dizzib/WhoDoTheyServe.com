_  = require \underscore
Hv = require \../../../model/hive .instance

module.exports = (vg) ->
  const ICON-SIZE = 20
  const GLYPHS =
    bank :\\uf19c
    film :\\uf008
    music:\\uf001
    tv   :\\uf26c
  var nodes

  vg.on \render ->
    nodes := @svg.selectAll \g.node
      .data @d3f.nodes!
      .enter!append \svg:g
        .attr \class ->
          tag = if it.tags? then \tag else ''
          you = if is-you it then \you else ''
          "node id_#{it._id} #tag #you".trim!
    nodes
      ..append \svg:circle
        .attr \r -> 5 + it.weight + if is-you it then 10 else 0
      ..append \svg:a
        .attr \xlink:href -> "#/node/#{it._id}"
        .append \svg:text
          .attr \dy 4
          .attr \text-anchor \middle
          .text -> it.name
    append-glyph (@svg.selectAll \g.node.tag), -> GLYPHS[it.tags.0] # only render 1st

    for icon in icons =  (Hv.Map.get-prop \icons) or []
      g = @svg.select "g.id_#{icon.id}"
      if icon.glyph
        append-glyph g, -> icon.glyph
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

    ## helpers

    function append-glyph gs, fn-text
      gs.append \text
        .attr \class \fa
        .attr \font-family \FontAwesome
        .attr \font-size ICON-SIZE
        .attr \x ICON-SIZE * -0.5
        .attr \y ICON-SIZE * -0.75
        .text fn-text

    function is-you then /^YOU/.test it.name

  vg.on \tick ->
    nodes.attr \transform -> "translate(#{it.x},#{it.y})"
