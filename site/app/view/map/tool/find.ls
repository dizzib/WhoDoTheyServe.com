B  = require \backbone
F  = require \fs
_  = require \underscore
Vs = require \../../../view-activity/select

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/find.html
    @v-sel = new Vs.SelectView el:$ns = @$ \.names
    @$el.on \expand ~> @v-sel.open!

  render: (v-graph) ->
    return unless ns = v-graph.d3f.nodes!
    @v-sel.render ns, \name
    @v-sel.on \selected (id) ~>
      return unless id
      @trigger \select id
      @v-sel.clear!blur!
      @$el.addClass \collapsed
