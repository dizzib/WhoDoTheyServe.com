B = require \backbone
F = require \fs
_ = require \underscore

const LAYERS =
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
    function toggle css-class, state then v-graph.$el.toggleClass css-class, state
    for let id, cfg of LAYERS
      @$ "\#chk#id"
        ..prop \checked cfg.default
        ..click -> toggle cfg.class, $ @ .prop \checked
      toggle cfg.class, cfg.default
    @$el.show!
    @trigger \rendered

    v-graph.on \cooled ~>
      n = 0
      for let id, cfg of LAYERS
        n += len = v-graph.$el.find "line.#{cfg.class}:first" .length
        @$ "\#chk#id" .parents \.layer .toggleClass \hide len is 0
      @$el.toggle n > 0
