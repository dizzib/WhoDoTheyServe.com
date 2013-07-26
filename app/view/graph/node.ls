F = require \fs
_ = require \underscore
I = require \../../lib-3p/insert-css
C = require \../../collection
M = require \../../model

I F.readFileSync __dirname + \/node.css

exports
  ..data = ->
    _.map C.Nodes.models, (m) -> m.toJSON-T!

  ..init = (svg, d3-force) ~>
    @nodes = svg.selectAll \g.node
      .data d3-force.nodes!
      .enter!append \svg:g
        .attr \class, -> "node id_#{it._id} #{if exports.is-you it then \you}"

    @nodes.append \svg:circle
      .attr \r, -> 5 + it.weight + if exports.is-you it then 10 else 0

    @nodes.append \svg:a
      .attr \xlink:href, -> "#/node/#{it._id}"
      .append \svg:text
        .attr \dy, 4
        .attr \text-anchor, \middle
        .text -> it.name

    if images = (JSON.parse M.Hive.Graph.get \value).images then
      for image in images
        dimensions = image.size / \x
        svg.select "g.id_#{image.id}" .append \svg:image
          .attr \xlink:href, image.url
          .attr \x     , -dimensions.0 / 2
          .attr \y     , -dimensions.1 - 12
          .attr \width , dimensions.0
          .attr \height, dimensions.1

  ..is-bis = ->
    /^BIS /.test it.name

  ..is-you = ->
    /^YOU/.test it.name

  ..on-tick = ~>
    @nodes.attr \transform, ~> "translate(#{it.x},#{it.y})"
