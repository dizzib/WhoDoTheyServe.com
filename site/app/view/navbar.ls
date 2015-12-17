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

    ## helpers

    function render-map-tabs
      const SEL = \.nav>li.map
      return unless m = V.maps.get-current!
      key = m.id or \new
      unless @$ "#SEL[data-key=#key]" .length
        $t = @$ "#SEL:not([data-key])" .first!
        $t = @$ "#SEL.hot" unless $t.length
        $t.render m, D.map
        $t.attr \data-key key
        $t.attr \active "^$|^map/#key"
      @$ SEL .each -> ($t = $ @).toggleClass \hot key is $t.attr \data-key

    function render-maps-dropdown
      $maps = @$ \ul.maps
      uid = S.get-id! or C.Users.find(-> it.get-is-admin!).models.0?id
      maps = C.Maps.where 'meta.create_user_id':uid
      json = _.map maps, -> it.toJSON-T!
      $maps.render json, D.nav-maps
      $new = @$ \li.map-new
      if V.maps.get-current!?isNew!
        $new.addClass \active .find \i.edit-indicator .addClass 'fe fe-chevron-left'
      $maps.append $new

    function set-active-tab
      function clean-hash then it.replace('#/' '').replace '#'  ''
      @$ \.nav>li .each ->
        $li = $ @
        return unless (s = $li.attr \active)?
        $li.toggleClass \active (new RegExp s, \i).test (clean-hash location.hash)
      @$ \.nav>li.active>a .focus!
