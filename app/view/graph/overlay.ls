F = require \fs
C = require \../../collection
I = require \../../lib-3p/insert-css
V = require \../../view

I F.readFileSync __dirname + \/overlay.css

class Overlay
  (@tag, @fn-edge-is-match, @fn-node-is-match) ->

  init: (svg, @f) ~>
    @g-root = svg.append \svg:g .attr \class, @tag
    append-badges!
    V.graph-toolbar.on "toggle-#{@tag}", ~>
      @g-root.attr \display, if it then '' else \none

    ~function append-badges then
      for edge in @edges
        evs  = _.filter C.Evidences.models, -> edge._id is it.get \entity_id
        url  = if evs.length is 1 then evs.0.get \url else "#/edge/#{edge._id}"
        tip  = if evs.length is 1 then edge.tip else ''
        node = if @fn-node-is-match edge.source then edge.target else edge.source
        slit = d3.select ".id_#{node._id} .slit"
        slit.append \svg:a
          .attr \class      , "badge-#{@tag}"
          .attr \target     , \_blank
          .attr \xlink:href , -> url
          .attr \xlink:title, -> tip
          .append \svg:text
            .attr \font-size  , 10
            .attr \text-anchor, \middle
            .text @tag.toUpperCase!

  filter-edges: (edges) ~> # must be called before init
    groups = _.groupBy edges, ~>
      if @fn-edge-is-match it and node-is-match it then \yes else \no
    @edges = groups.yes or []
    return groups.no

    ~function node-is-match then
      @fn-node-is-match it.source or @fn-node-is-match it.target

  render: ~>
    return unless @edges.length
    node = _.find @f.nodes!, @fn-node-is-match
    @g = @g-root.append \svg:g
    for edge in @edges
      [src, tar] = [edge.source, edge.target]
      @g.append \svg:line
        .attr \x1, if @fn-node-is-match src then node.x else src.x
        .attr \y1, if @fn-node-is-match src then node.y else src.y
        .attr \x2, if @fn-node-is-match tar then node.x else tar.x
        .attr \y2, if @fn-node-is-match tar then node.y else tar.y
        .attr \class, "edge #{@tag}"

  render-clear: ~>
    @g?remove!

exports
  ..Cfr = new Overlay \cfr, (-> it.how is \member)  , (-> /^CFR/.test it.name)
  ..Bis = new Overlay \bis, (-> it.how is \director), (-> /^BIS/.test it.name)
