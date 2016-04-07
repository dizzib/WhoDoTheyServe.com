_ = require \underscore

module.exports = (vg, edge-glyph, bn = bil-node) ->
  var edges-attend, edges-steer, nodes-steer, ga, g-attend, gs, g-steer

  vg.on \cooled ->
    ~function render g, edges, fn-get-hub, fn-is-satellite, css-class
      return unless hub = _.find @d3f.nodes!, fn-get-hub
      g-child = g.append \svg:g
      for e in edges
        e.source = hub if fn-is-satellite e.source
        e.target = hub if fn-is-satellite e.target
        g-child.append \svg:line
          .attr \x1 e.source.x
          .attr \y1 e.source.y
          .attr \x2 e.target.x
          .attr \y2 e.target.y
          .attr \class "edge layer id_#{e._id} #css-class #{e.classes * ' '}".trim!
          .datum e
      g-child.selectAll \g.edge-glyphs
        .data edges
        .enter!append \svg:g
          .attr \class -> "edge-glyphs layer id_#{it._id} #css-class #{it.classes * ' '}".trim!
        .each edge-glyph.append
        .attr \transform edge-glyph.get-transform
      g-child

    if edges-attend
      edges = _.reject edges-attend, (edge) ->
        !!_.find nodes-steer, -> it._id in [edge.source._id, edge.target._id]
      g-attend := render ga, edges, bn.is-annual-conference, bn.is-conference-yyyy, \bil-attend
    if edges = edges-steer
      g-steer := render gs, edges, bn.is-steering, bn.is-steering, \bil-steer

  vg.on \late-render ->
    ~function add-overlay name then @svg.append \svg:g .attr \class name
    ga := add-overlay \bil-attend
    gs := add-overlay \bil-steer

  vg.on \pre-cool ->
    g-attend?remove!
    g-steer?remove!

  vg.on \pre-render (ents) ->
    function is-conf-yyyy then bn.is-conference-yyyy it.source or bn.is-conference-yyyy it.target
    function is-steering then it.how is \member and (bn.is-steering it.source or bn.is-steering it.target)

    edges-conf    = _.filter ents.edges, is-conf-yyyy
    edges-attend := _.filter edges-conf, -> it.how is \attends
    edges-steer  := _.filter ents.edges, is-steering
    nodes-steer  := _.map edges-steer, -> if bn.is-steering it.source then it.target else it.source
    ents.edges    = _.difference ents.edges, edges-conf, edges-steer

    # inject info required by node renderer
    bn.edges-attend = edges-attend
    bn.nodes-steer = nodes-steer
