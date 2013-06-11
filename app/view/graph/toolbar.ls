B = require \backbone
F = require \fs
I = require \../../lib-3p/insert-css

I F.readFileSync __dirname + \/toolbar.css
T = F.readFileSync __dirname + \/toolbar.html

module.exports = B.View.extend do
  render: ->
    @$el.append T
    init \#chkBBergAttend, \toggle-bberg-attend
    init \#chkBBergSteer , \toggle-bberg-steer

    ~function init id, event
      $el = $ id
        ..prop \checked, true
        ..click ~> @trigger event, $el.prop \checked
