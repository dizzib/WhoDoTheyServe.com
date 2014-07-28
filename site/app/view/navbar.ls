B = require \backbone
F = require \fs
C = require \../collection
D = require \../view-directive
H = require \../helper
S = require \../session
V = require \../view

T = F.readFileSync __dirname + \/navbar.html

H.insert-css F.readFileSync __dirname + \/navbar.css

module.exports = B.View.extend do
  render: ->
    @set-active-tab $t = $ T
    render-map!
    render-maps-dropdown!
    @$el.html $t .show!
    S.auto-sync-el @$el

    function render-map
      $el = $t.find \>li.map
      if (m = V.map.map)? then $el.render m, D.map else $el.remove!

    function render-maps-dropdown
      $maps = $t.find \ul.maps
      if C.Maps.length then ($maps.render C.Maps.toJSON-T!, D.maps) else $maps.empty!
      $new = $t.find \li.map-new
      $new.addClass \active .find \i.edit-indicator .addClass 'fa fa-chevron-left' if V.map.map?isNew!
      $maps.append $new

  set-active-tab: ($t) ->
    $t.find \>li .each ->
      return unless (s = ($this = $ this).attr \active)?
      $this.toggleClass \active, (new RegExp s, \i).test (clean-hash location.hash)

    function clean-hash hash then
      hash
       .replace '#/', ''
       .replace '#' , ''
