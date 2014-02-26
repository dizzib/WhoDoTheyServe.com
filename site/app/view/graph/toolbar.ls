B = require \backbone
F = require \fs
H = require \../../helper
S = require \../../session

H.insert-css F.readFileSync __dirname + \/toolbar.css
T = F.readFileSync __dirname + \/toolbar.html

module.exports = B.View.extend do
  render: ->
    @$el.append T
    S.auto-sync-el @$el.find \.toolbar

    $ \#btnSaveLayout .click ~> @trigger \save-layout

    init-overlay-chk \#chkAc       , \toggle-ac        , false
    init-overlay-chk \#chkBilAttend, \toggle-bil-attend, false
    init-overlay-chk \#chkBilSteer , \toggle-bil-steer , true
    init-overlay-chk \#chkCfr      , \toggle-cfr       , false
    init-overlay-chk \#chkBis      , \toggle-bis       , false

    ~function init-overlay-chk id, event, value
      $el = $ id
        ..prop \checked, value
        ..click ~> @trigger event, $el.prop \checked
      @trigger event, value
