F  = require \fs
_  = require \underscore
H  = require \../../helper
Hv = require \../../model/hive .instance

const ICON-SIZE = 20

H.insert-css F.readFileSync __dirname + \/node.css

var nodes

module.exports = me =
  is-bis: ->
    /^BIS /.test it.name

  is-you: ->
    /^YOU/.test it.name

  refresh-position: ->
    nodes.attr \transform, -> "translate(#{it.x},#{it.y})"

  render: (svg, d3f) ->
    nodes := svg.selectAll \g.node
      .data d3f.nodes!
      .enter!append \svg:g
        .attr \class, ->
          "node id_#{it._id} #{if me.is-you it then \you else ''}".trim!

    nodes.append \svg:circle
      .attr \r, -> 5 + it.weight + if me.is-you it then 10 else 0

    nodes.append \svg:a
      .attr \xlink:href, -> "#/node/#{it._id}"
      .append \svg:text
        .attr \dy, 4
        .attr \text-anchor, \middle
        .text -> it.name

    if icons = (JSON.parse Hv.Map.get \value).icons
      for icon in icons
        g = svg.select "g.id_#{icon.id}"
        if icon.glyph
          g.append \text
            .attr \class, \fa
            .attr \font-family, \FontAwesome
            .attr \font-size, ICON-SIZE
            .attr \x, - ICON-SIZE * 0.5
            .attr \y, - ICON-SIZE * 0.75
            .text -> icon.glyph
        else if icon.image
          size = icon.size / \x
          g.append \svg:image
            .attr \xlink:href, icon.image
            .attr \x     , x = -size.0 / 2
            .attr \y     , y = -size.1 - 12
            .attr \width , size.0
            .attr \height, size.1
          if size.2
            g.append \svg:rect
              .attr \x     , x - 1
              .attr \y     , y - 1
              .attr \width , 2 + parseInt size.0
              .attr \height, 2 + parseInt size.1
