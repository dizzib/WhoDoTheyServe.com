B = require \backbone
F = require \fs
_ = require \underscore

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
    function toggle css-class, state then v-graph.$el.toggleClass css-class, state
    for let id, cfg of OVERLAYS
      @$ "\#chk#id"
        ..prop \checked cfg.default
        ..click -> toggle cfg.class, $ @ .prop \checked
      toggle cfg.class, cfg.default
    @$el.show!
    @trigger \rendered

    v-graph.on \cooled ~>
      @$el.show!
      for let id, cfg of OVERLAYS
        layer-exists = v-graph.$el.find "line.#{cfg.class}:first" .length > 0
        @$ "\#chk#id" .parents \.layer .toggle layer-exists
      group-lengths = @$ \.group .map(-> $ @ .find \.layer:visible .length).get!
      @$ \hr .toggle(group-lengths.0 > 0 and group-lengths.1 > 0)
      @$el.hide! unless group-lengths.0 + group-lengths.1
