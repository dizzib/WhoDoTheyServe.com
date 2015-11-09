C = require \../../../collection

module.exports = (vg = v-graph) ->
  class Layer
    (@tag, @fn-edge-is-match, @fn-node-is-match) ->
      o = this

      vg.on \pre-render (entities) ->
        function node-is-match then o.fn-node-is-match it.source or o.fn-node-is-match it.target
        groups = _.groupBy entities.edges, ->
        o.edges = _.filter entities.edges, -> o.fn-edge-is-match it and node-is-match it
        for e in o.edges then e.classes ++= [ \layer o.tag ]

      vg.on \render -> # append-badges
        o.d3f = @d3f
        o.g-root = @svg.append \svg:g .attr \class o.tag
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

  new Layer \ac,
    -> true
    -> /^Atlantic Council$/.test it.name

  new Layer \bis,
    -> it.how is \director
    -> /^BIS/.test it.name

  new Layer \cfr,
    -> it.how is \member
    -> /^CFR/.test it.name
