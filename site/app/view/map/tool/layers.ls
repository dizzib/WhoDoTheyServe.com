B = require \backbone
F = require \fs

const OVERLAYS =
  Ac       : default:false class:\ac
  BilAttend: default:false class:\bil-attend
  BilSteer : default:true  class:\bil-steer
  Bis      : default:false class:\bis
  Cfr      : default:false class:\cfr
  OutOfDate: default:true  class:\out-of-date

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/layers.html

  render: (v-graph) ->
    @$el.show!
    $g = v-graph.$el
    for let k, v of OVERLAYS
      $c = @$ "\#chk#k" .click -> $g.toggleClass v.class, $c.prop \checked
      @$ "\#chk#k" .prop \checked v.default
      $g.toggleClass v.class, v.default
    @trigger \rendered
