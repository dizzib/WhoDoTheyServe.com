B  = require \backbone
F  = require \fs
_  = require \underscore
C  = require \../collection
Hm = require \../model/hive .instance.Map
S  = require \../session
V  = require \../view
D  = require \../view-handler/directive

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
      return unless map = V.maps.get-current! or C.Maps.get Hm.default-ids?0
      key = map.id or \new
      unless @$ "#SEL[data-key=#key]" .length
        $tab = @$ "#SEL:not([data-key]):first"
        $tab = @$ "#SEL.hot" unless $tab.length
        render $tab, key, map, \^$|
      if ($tab = @$ "#SEL:not([data-key])").length is 1 and id = Hm.default-ids?1
        render $tab, id, C.Maps.get id unless id is key # tab-2 default
      @$ SEL .each -> ($tab = $ @).toggleClass \hot key is $tab.attr \data-key

      function render $tab, key, map, active-rx = ''
        $tab.render map.toJSON-T!, D.map
        $tab.attr \data-key key .attr \active "#active-rx^map/#key"

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
