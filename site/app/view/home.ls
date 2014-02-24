B = require \backbone
_ = require \underscore
F = require \fs # browserified
C = require \../collection
H = require \../helper
S = require \../session
D = require \../view-directive

T-Latest = F.readFileSync __dirname + \/latest.html

module.exports = B.View.extend do
  render: ->
    @$el
      .empty!
      .append render-latest!
      .show!

    function render-latest then
      edges     = get-json C.Edges    , \edge
      nodes     = get-json C.Nodes    , \node
      notes     = get-json C.Notes    , \note
      all       = edges ++ nodes ++ notes
      by-date   = _.sortBy all, (x) -> x.meta.create_date
      latest    = _.first by-date.reverse!, 50
      directive = items: _.extend do
        D.edges, D.glyph, D.meta, D.nodes, D.notes
        item:
          fn: ->
            $ it.element .find ".entity>:not(.#{@type})" .remove!
            return void
      ($t = $ T-Latest).render items:latest, directive
      return $t

      function get-json coll, type then
        _.map coll.models, (x) -> _.extend x.toJSON-T!, type:type
