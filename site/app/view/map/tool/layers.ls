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
    @reset!

  render: ->
    for let k, v of OVERLAYS
      $el = get-chk$ k .click ~> @trigger (get-toggle-event v), $el.prop \checked
    @$el.show!
    @trigger \rendered

  reset: ->
    for let k, v of OVERLAYS
      get-chk$ k .prop \checked v.default
      @trigger (get-toggle-event v), v.default

## helpers

function get-chk$ then $ "\#chk#it"

function get-toggle-event then "toggle-#{it.event}"
