_ = require \underscore
W = require \../../../../lib/when

module.exports = (vg) ->
  var lines

  vg.on \pre-render (ents) ->
    map-when = vg.map.get \when
    map-when-int = if map-when then W.parse map-when, \max else W.get-int-today!
    function is-in-range then W.is-in-range map-when-int, it.int

    # Choose the single edge to render for node-pairs having chronological edges
    node-pairs = {}
    reject-ids = []
    for e in es = ents.edges
      [id0, id1] = [e.a_node_id, e.b_node_id]
      key = if id0 < id1 then "#id0,#id1" else "#id1,#id0" # treate A-B and B-A identically
      (node-pairs[key] ?= []).push e
    for k, v of node-pairs when v.length > 1
      p = _.partition v, -> is-in-range it.when-obj
      if p.0.length is 1 then reject-ids ++= _.pluck p.1, \_id else
        reject-ids ++= _.pluck v[0 til -1], \_id # all out of range, so just use the last one
    es = _.reject es, -> it._id in reject-ids

    ents.edges = _.map es, (edge) -> _.extend do
      edge
      source: _.find ents.nodes, -> it._id is edge.a_node_id
      target: _.find ents.nodes, -> it._id is edge.b_node_id

    for e in ents.edges
      e.classes.push "id_#{e._id}"
      e.classes.push \out-of-date if not is-in-range e.when-obj
      e.classes.push \family if a = e.source.family-name and b = e.target.family-name and a is b

  vg.on \render ->
    @svg.append \svg:defs .selectAll \marker
      .data <[ end ]>
      .enter!append \svg:marker
        .attr \id           String
        .attr \viewBox      '0 -5 10 10'
        .attr \refX         20
        .attr \markerWidth  15
        .attr \markerHeight 15
        .attr \markerUnits  \userSpaceOnUse
        .attr \orient       \auto
      .append \svg:path
        .attr \d, 'M0,-5L10,0L0,5'
    lines := @svg.selectAll \line
      .data @d3f.links!
      .enter!append \svg:line
        .attr \class      -> "edge #{it.class}".trim!
        .attr \marker-end -> if it.a_is is \lt then 'url(#end)' else ''

  vg.on \tick ->
    lines
      .attr \x1 -> it.source.x
      .attr \y1 -> it.source.y
      .attr \x2 -> it.target.x
      .attr \y2 -> it.target.y
