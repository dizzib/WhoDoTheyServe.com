C = require \../../collection
V = require \../../view

class Overlay
  (@tag, @fn-edge-is-match, @fn-node-is-match) ->
    o = this
    vg = V.map.v-graph

    vg.on \cooled ->
      return unless o.edges.length
      node = _.find o.d3f.nodes!, o.fn-node-is-match
      o.g = o.g-root.append \svg:g
      for edge in o.edges
        [src, tar] = [edge.source, edge.target]
        o.g.append \svg:line
          .attr \x1 if o.fn-node-is-match src then node.x else src.x
          .attr \y1 if o.fn-node-is-match src then node.y else src.y
          .attr \x2 if o.fn-node-is-match tar then node.x else tar.x
          .attr \y2 if o.fn-node-is-match tar then node.y else tar.y
          .attr \class "edge id_#{edge._id} #{o.tag}"

    vg.on \pre-cool ->
      o.g?remove!

    vg.on \pre-render (entities) ->
      function node-is-match then o.fn-node-is-match it.source or o.fn-node-is-match it.target
      groups = _.groupBy entities.edges, ->
        if o.fn-edge-is-match it and node-is-match it then \yes else \no
      o.edges = groups.yes or []
      entities.edges = groups.no

    vg.on \render ->
      o.d3f = @d3f
      o.g-root = @svg.append \svg:g .attr \class o.tag
      append-badges!
      V.map.v-layers.on "toggle-#{o.tag}" ~>
        o.g-root.attr \display if it then '' else \none

      function append-badges
        for edge in o.edges
          evs  = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
          url  = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge._id}"
          tip  = if evs.length is 1 then edge.tip else ''
          node = if o.fn-node-is-match edge.source then edge.target else edge.source
          slit = d3.select ".id_#{node._id} .slit"
          slit.append \svg:a
            .attr \class       "badge-#{o.tag}"
            .attr \target      \_blank
            .attr \xlink:href  -> url
            .attr \xlink:title -> tip
            .append \svg:text
              .attr \font-size   10
              .attr \text-anchor \middle
              .text o.tag.toUpperCase!

new Overlay \ac,
  -> true
  -> /^Atlantic Council$/.test it.name

new Overlay \bis,
  -> it.how is \director
  -> /^BIS/.test it.name

new Overlay \cfr,
  -> it.how is \member
  -> /^CFR/.test it.name
