B = require \backbone
F = require \fs
S = require \../../../session

const OVERLAYS =
  Ac       : default:false event:\ac
  BilAttend: default:false event:\bil-attend
  BilSteer : default:true  event:\bil-steer
  Bis      : default:false event:\bis
  Cfr      : default:false event:\cfr

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/layers.html

  render: (v-graph) ->
    @$el.show!
    $g = v-graph.$el
    for let k, v of OVERLAYS
      $c = @$ "\#chk#k" .click -> $g.toggleClass v.event, $c.prop \checked
      @$ "\#chk#k" .prop \checked v.default
      $g.toggleClass v.event, v.default
    @trigger \rendered
