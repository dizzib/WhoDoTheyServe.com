B = require \backbone
F = require \fs
C = require \../collection
D = require \../view-directive
H = require \../helper
S = require \../session

T = F.readFileSync __dirname + \/navbar.html

H.insert-css F.readFileSync __dirname + \/navbar.css

module.exports = B.View.extend do
  render: ->
    @set-active-tab $t = $ T
    $t.find \ul.maps .render(C.Maps.toJSON-T!, D.maps) .append $t.find \li.map-new
    @$el.html $t .show!
    S.auto-sync-el @$el

  set-active-tab: ($t) ->
    $t.find \>li .each ->
      regex = new RegExp ($this = $ this).attr(\active), \i
      $this.toggleClass \active, regex.test (clean-hash location.hash)

    function clean-hash hash then
      hash
       .replace '#/', ''
       .replace '#' , ''
