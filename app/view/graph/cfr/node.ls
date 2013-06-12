F = require \fs
_ = require \underscore
C = require \../../../collection
I = require \../../../lib-3p/insert-css
E = require \./edge

I F.readFileSync __dirname + \/node.css

exports
  ..init = (svg, d3-force) ->
    for edge in E?edges
      evs  = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
      url  = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge._id}"
      tip  = if evs.length is 1 then "Evidence member of CFR" else ''
      node = if exports.is-cfr edge.source then edge.target else edge.source
      d3-badge = d3.select ".id_#{node._id}" .append \svg:g
        .attr \class    , 'badge-cfr'
        .attr \transform, -> 'translate(0,-10)'
      d3-badge.append \svg:a
        .attr \target     , \_blank
        .attr \xlink:href , -> url
        .attr \xlink:title, -> tip
        .append \svg:text
          .attr \font-size  , 10
          .attr \text-anchor, \middle
          .text \CFR

  ..is-cfr = ->
    /^CFR/.test it.name
