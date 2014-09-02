B = require \backbone
F = require \fs
H = require \../../helper
S = require \../../session

const OVERLAYS =
  Ac       : default:false, event:\ac
  BilAttend: default:false, event:\bil-attend
  BilSteer : default:true , event:\bil-steer
  Cfr      : default:false, event:\cfr
  Bis      : default:false, event:\bis

module.exports = B.View.extend do

  initialize: ->
    H.insert-css F.readFileSync __dirname + \/toolbar.css
    @$el.html F.readFileSync __dirname + \/toolbar.html

    for let k, v of OVERLAYS
      $el = get-chk$ k .click ~> @trigger (get-toggle-event v), $el.prop \checked
    @reset!

  reset: ->
    for let k, v of OVERLAYS
      get-chk$ k .prop \checked, v.default
      @trigger (get-toggle-event v), v.default

  show: ->
    @$el.show!

## helpers

function get-chk$ then $ "\#chk#it"

function get-toggle-event then "toggle-#{it.event}"
