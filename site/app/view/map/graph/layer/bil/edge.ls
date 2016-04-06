_ = require \underscore

module.exports = (vg, edge-glyph, bn = bil-node) ->
  var edges-attend, edges-steer, nodes-steer, ga, g-attend, gs, g-steer

  vg.on \cooled ->
    ~function render g, edges, fn-get-hub, fn-is-hub, css-class
      return unless hub = _.find @d3f.nodes!, fn-get-hub
      g-child = g.append \svg:g
      for e in edges
        [src, tar] = [e.source, e.target]
        g-child.append \svg:line
          .attr \x1 if fn-is-hub src then hub.x else src.x
          .attr \y1 if fn-is-hub src then hub.y else src.y
          .attr \x2 if fn-is-hub tar then hub.x else tar.x
          .attr \y2 if fn-is-hub tar then hub.y else tar.y
          .attr \class "edge id_#{e._id} layer #{css-class} #{e.classes * ' '}".trim!
          .datum e
      g-child

    # attends
    if edges-attend
      edges = _.reject edges-attend, (edge) ->
        !!_.find nodes-steer, -> it._id in [edge.source._id, edge.target._id]
      g-attend := render ga, edges, bn.is-annual-conference, bn.is-conference-yyyy, \bil-attend

    # steering
    return unless edges = edges-steer
    return unless g-steer := render gs, edges, bn.is-steering, bn.is-steering, \bil-steer
    glyphs = g-steer.selectAll \g.edge-glyphs
      .data edges
      .enter!append \svg:g
        .attr \class 'edge-glyphs layer bil-steer'
    glyphs.each edge-glyph.append
    glyphs.attr \transform edge-glyph.get-transform

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
