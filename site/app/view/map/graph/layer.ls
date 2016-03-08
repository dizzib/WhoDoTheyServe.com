const LAYERS =
  ac : rx:/^Atlantic Council$/
  bis: rx:/^BIS/ how:\director
  cfr: rx:/^CFR/ how:\member

module.exports = (vg) ->
  class Layer
    (@tag, @fn-edge-is-match, @fn-node-is-match) ->
      o = this

      vg.on \pre-render (ents) ->
        function node-is-match then o.fn-node-is-match it.source or o.fn-node-is-match it.target
        groups = _.groupBy ents.edges, ->
        o.edges = _.filter ents.edges, -> o.fn-edge-is-match it and node-is-match it
        for e in o.edges then e.classes ++= [ \layer o.tag ]

      vg.on \late-render -> # append-badges
        o.d3f = @d3f
        o.g-root = @svg.append \svg:g .attr \class o.tag
        for edge in o.edges
          evs  = @evs-by-entity-id[edge._id]
          url  = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge._id}"
          tip  = if evs.length is 1 then edge.tip else ''
          node = if o.fn-node-is-match edge.source then edge.target else edge.source
          slit = @svg.select ".id_#{node._id} .slit"
          slit.append \svg:a
            .attr \class       "badge-#{o.tag}"
            .attr \target      \_blank
            .attr \xlink:href  -> url
            .attr \xlink:title -> tip
            .append \svg:text
              .attr \font-size   10
              .attr \text-anchor \middle
              .text o.tag.toUpperCase!

  for let tag, cfg of LAYERS then new Layer tag,
    -> if cfg.how then (it.how is cfg.how) else true
    -> cfg.rx.test it.name
