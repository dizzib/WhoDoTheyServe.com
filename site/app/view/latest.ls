B = require \backbone
_ = require \underscore
F = require \fs # browserified
C = require \../collection
E = require \../entities
H = require \../helper
S = require \../session
D = require \../view-directive

T-Latest = F.readFileSync __dirname + \/latest.html

module.exports = B.View.extend do
  render: ->
    <~ E.fetch-all # ensure all entities are loaded
    @$el.html render-latest! .show!

    function render-latest
      # prefix classes with 'sel-' to ensure they don't clash with directives
      edges = get-json C.Edges, \sel-edge
      maps  = get-json C.Maps , \sel-map
      nodes = get-json C.Nodes, \sel-node
      notes = get-json C.Notes, \sel-note # possibly may not have loaded (see boot.ls)

      all     = edges ++ maps ++ nodes ++ notes
      by-date = _.sortBy all, (x) -> x.meta.update_date or x.meta.create_date
      latest  = _.first by-date.reverse!, 50

      directive = items: _.extend do
        D.edges, D.map, D.meta-compact, D.nodes, D.notes
        item:
          fn: ->
            $ it.element .find ".entity>:not(.#{@type})" .remove!
            void
      ($t = $ T-Latest).render items:latest, directive
      $t

# helpers

function get-json coll, type then _.map coll.models, (x) -> _.extend x.toJSON-T!, type:type
