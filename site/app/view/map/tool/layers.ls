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

  render: ->
    for let k, v of OVERLAYS
      $c = @$ "\#chk#k" .click ~> @trigger "toggle-#{v.event}" $c.prop \checked
    @$el.show!
    @trigger \rendered
    @reset!

  reset: ->
    for let k, v of OVERLAYS
      @$ "\#chk#k" .prop \checked v.default
      @trigger "toggle-#{v.event}" v.default
