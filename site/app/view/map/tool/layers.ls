B = require \backbone
F = require \fs

const OVERLAYS =
  Ac       : default:false class:\ac
  BilAttend: default:false class:\bil-attend
  BilSteer : default:true  class:\bil-steer
  Bis      : default:false class:\bis
  Cfr      : default:false class:\cfr
  OutOfDate: default:false class:\out-of-date

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/layers.html

  render: (v-graph) ->
    for let k, v of OVERLAYS
      @$ "\#chk#k"
        ..prop \checked v.default
        ..click -> toggle v.class, $ @ .prop \checked
      toggle v.class, v.default

    @$el.show!
    @trigger \rendered

    function toggle css-class, state
      v-graph.$el.toggleClass css-class, state
