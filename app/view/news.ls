B = require \backbone
_ = require \underscore
F = require \fs # browserified
C = require \../collection
H = require \../helper
S = require \../session
D = require \../view-directive

T = F.readFileSync __dirname + \/news.html

module.exports = B.View.extend do
  render: ->
    edges     = get-json C.Edges    , \edge
    evidences = get-json C.Evidences, \evidence
    nodes     = get-json C.Nodes    , \node
    notes     = get-json C.Notes    , \note
    all       = edges ++ evidences ++ nodes ++ notes
    by-date   = _.sortBy all, (x) -> x.meta.create_date
    latest    = _.first by-date.reverse!, 50
    directive = _.extend do
      D.edges, D.evidences, D.glyph, D.meta, D.nodes, D.notes
      item:
        null: -> $ it.element .find ".entity>:not(.#{@type})" .hide!
    ($t = $ T).render latest, directive
    @$el.html $t .show!

    function get-json coll, type then
      _.map coll.models, (x) -> _.extend x.toJSON-T!, type:type
