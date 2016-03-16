_  = require \underscore
Hv = require \../../../model/hive .instance

module.exports = (vg) ->
  const ICON-SIZE = 20
  const GLYPHS =
    bank     : \\ue827
    film     : \\ue823
    magazine : \\ue832
    music    : \\ue822
    newspaper: \\ue824
    person   : \\ue801
    tv       : \\ue808
  var nodes

  vg.on \pre-render (ents) ->
    for n in ents.nodes
      n.classes = []
      n.classes.push \tag if n.tags?length
      n.classes.push \person if n.is-person
      n.classes.push \you if is-you n

  vg.on \render ->
    nodes := @svg.selectAll \g.node
      .data @d3f.nodes!
      .enter!append \svg:g
        .attr \class -> "node id_#{it._id} #{it.class}".trim!
    nodes
      ..append \svg:circle
        .attr \r -> 5 + it.weight + if is-you it then 30 else 0
      ..append \svg:a
        ..attr \xlink:href -> "#/node/#{it._id}"
        ..append \svg:text
          .attr \dy 4
          .attr \text-anchor \middle
          .text -> it.name
        ..append \title
          .text -> "#{it.name} #{it.when-text}".trim!
        ..each ->
          return unless it.when-text
          d3.select this .append \svg:text
            .attr \dy 22
            .attr \text-anchor \middle
            .text -> it.when-text
    append-glyph (@svg.selectAll \g.node.person), GLYPHS.person, \person
    append-glyph (@svg.selectAll \g.node.tag), (-> GLYPHS[it.tags.0]), (-> it.tags.join ', ')

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

    function append-glyph gs, fn-text, fn-tooltip
      gs.append \text
        .attr \class \fe
        .attr \font-family \fontello
        .attr \font-size ICON-SIZE
        .attr \x ICON-SIZE * -0.5
        .attr \y ICON-SIZE * -0.75
        .text fn-text
        .append \title
          .text fn-tooltip

  vg.on \tick ->
    nodes.attr \transform -> "translate(#{it.x},#{it.y})"

  function is-you then /^YOU/.test it.name
