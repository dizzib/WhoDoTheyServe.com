B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
D = require \../view-handler/directive
S = require \../session
V = require \../view

module.exports = B.View.extend do
  initialize: ->
    @T = F.readFileSync __dirname + \/navbar.html
    B.on 'routed signin signout' ~> @render!

  render: ->
    set-active-tab $t = $ @T
    render-map $t
    render-maps-dropdown $t
    @$el.html $t .show!
    S.auto-sync-el @$el

## helpers

function render-map $t
  $el = $t.find \>li.map
  if (m = V.map.map)? then $el.render m, D.map else $el.remove!

function render-maps-dropdown $t
  $maps = $t.find \ul.maps

  if C.Maps.length
    uid = S.get-id! or C.Users.find(-> it.get-is-admin!).models.0.id
    maps = C.Maps.where 'meta.create_user_id':uid
    json = _.map maps, -> it.toJSON-T!
    $maps.render json, D.nav-maps
  else
    $maps.empty!

  # create new
  $new = $t.find \li.map-new
  $new.addClass \active .find \i.edit-indicator .addClass 'fa fa-chevron-left' if V.map.map?isNew!
  $maps.append $new

function set-active-tab $t
  $t.find \>li .each ->
    return unless (s = ($this = $ this).attr \active)?
    $this.toggleClass \active, (new RegExp s, \i).test (clean-hash location.hash)

  function clean-hash hash
    hash
     .replace '#/' ''
     .replace '#'  ''
