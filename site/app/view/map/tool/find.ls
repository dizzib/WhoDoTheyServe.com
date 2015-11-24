B  = require \backbone
F  = require \fs
_  = require \underscore
Vs = require \../../../view-activity/select

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/find.html
    @v-sel = new Vs.SelectView el:@$ \.names

  render: (v-graph) ->
    return unless ns = v-graph.d3f.nodes!
    @v-sel.render ns, \name
    @v-sel.on \selected (id) ~>
      @trigger \select id if id
      @v-sel.set-by-id ''
