F = require \fs
_ = require \underscore
I = require \../../lib-3p/insert-css
C = require \../../collection

I F.readFileSync __dirname + \/node.css

exports
  ..data = ->
    _.map C.Nodes.models, (m) -> m.toJSON-T!

  ..init = (svg, d3-force) ~>
    @nodes = svg.selectAll \g.node
      .data d3-force.nodes!
      .enter!append \svg:g
        .attr \class, -> "node id_#{it._id} #{if exports.is-you it then \you}"
        .call d3-force.drag

    @nodes.append \svg:circle
      .attr \r, -> 5 + it.weight + if exports.is-you it then 10 else 0

    @nodes.append \svg:a
      .attr \xlink:href, -> "#/node/#{it._id}"
      .append \svg:text
        .attr \dy, 4
        .attr \text-anchor, \middle
        .text -> it.name

  ..is-bis = ->
    /^BIS /.test it.name

  ..is-you = ->
    /^YOU/.test it.name

  ..on-tick = ~>
    @nodes.attr \transform, ~> "translate(#{it.x},#{it.y})"
