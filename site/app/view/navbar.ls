B = require \backbone
F = require \fs
_ = require \underscore
C = require \../collection
D = require \../view-handler/directive
S = require \../session
V = require \../view

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/navbar.html

  render: ->
    render-map-tabs!
    render-maps-dropdown!
    set-active-tab!
    S.auto-sync-el @$el

    ## helpers

    function render-map-tabs
      const SEL = \.nav>li.map
      return unless m = V.maps.get-current!
      id = m.id
      unless @$ "#SEL[data-id=#id]" .length
        $t = @$ "#SEL:not([data-id])" .first!
        $t = @$ "#SEL.hot" unless $t.length
        $t.render m, D.map
        $t.attr \data-id id
        $t.attr \active "^$|^map/#id"
      @$ SEL .each -> ($t = $ @).toggleClass \hot id is $t.attr \data-id

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
      @$ \.nav>li .each ->
        $li = $ @
        return unless (s = $li.attr \active)?
        $li.toggleClass \active (new RegExp s, \i).test (clean-hash location.hash)
