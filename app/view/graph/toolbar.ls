B = require \backbone
F = require \fs
I = require \../../lib-3p/insert-css

I F.readFileSync __dirname + \/toolbar.css
T = F.readFileSync __dirname + \/toolbar.html

module.exports = B.View.extend do
  render: ->
    @$el.append T
    init \#chkBBergAttend, \toggle-bberg-attend, false
    init \#chkBBergSteer , \toggle-bberg-steer , true
    init \#chkCfr        , \toggle-cfr         , false

    ~function init id, event, value
      $el = $ id
        ..prop \checked, value
        ..click ~> @trigger event, $el.prop \checked
      @trigger event, value
