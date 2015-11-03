B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
D = require \../view-handler/directive
S = require \../session
V = require \../view

module.exports = B.View.extend do
  render: ->
    @$el.html F.readFileSync __dirname + \/navbar.html
    set-active-tab!
    render-map!
    render-maps-dropdown!
    S.auto-sync-el @$el

    ## helpers

    function render-map
      $map = @$ \ul.nav>li.map
      if (m = V.maps.get-current!)? then $map.show!render m, D.map else $map.hide!

    function render-maps-dropdown
      $maps = @$ \ul.maps
      if C.Maps.length
        uid = S.get-id! or C.Users.find(-> it.get-is-admin!).models.0.id
        maps = C.Maps.where 'meta.create_user_id':uid
        json = _.map maps, -> it.toJSON-T!
        $maps.render json, D.nav-maps
      else
        $maps.empty!
      # create new
      $new = @$ \li.map-new
      if V.maps.get-current!?isNew!
        $new.addClass \active .find \i.edit-indicator .addClass 'fa fa-chevron-left'
      $maps.append $new

    function set-active-tab
      function clean-hash then it.replace('#/' '').replace '#'  ''
      @$ \ul.nav>li .each ->
        return unless (s = ($li = $ @).attr \active)?
        $li.toggleClass \active (new RegExp s, \i).test (clean-hash location.hash)
