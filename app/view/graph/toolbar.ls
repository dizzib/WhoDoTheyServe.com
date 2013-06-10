B = require \backbone
F = require \fs
I = require \../../lib-3p/insert-css

I F.readFileSync __dirname + \/toolbar.css
T = F.readFileSync __dirname + \/toolbar.html

module.exports = B.View.extend do
  render: ->
    @$el.append T
    $bberg = $ \#chkBBerg
      ..prop \checked, true
      ..click ~> @trigger \toggle-bberg, $bberg.prop \checked
