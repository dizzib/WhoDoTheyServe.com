Bh  = require \backbone .history
C   = require \../collection
R   = require \../router
Si  = require \../signin
V   = require \../view
Vee = require \../view/edge/edit
Vev = require \../view/evidence
Vue = require \../view/user/edit
Vus = require \../view/user/signin

const KEYCODE-ESC = 27

module.exports =
  init: ->
    $ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!
    V
      ..edge-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, -> R.navigate \edges
        ..on \rendered ,    Vee.init
        ..on \saved    , -> nav-entity-saved \edge, &0, &1
      ..evidence-edit
        ..on \rendered ,    Vev.init
      ..map-edit
        ..on \destroyed, -> R.navigate \user
        ..on \saved    , (map, is-new) -> R.navigate "map/#{map.id}" if is-new
      ..node-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, -> R.navigate \nodes
        ..on \rendered , -> $ \#name .typeahead source:C.Nodes.pluck \name
        ..on \saved    , -> nav-entity-saved \node, &0, &1
      ..user-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed,    Vue.after-delete
        ..on \rendered ,    Vue.init
        ..on \saved    , -> R.navigate "user/#{it.id}"
      ..user-signin
        ..on \cancelled, -> Bh.history.back!
        ..on \error    , -> Vus.toggle-please-wait false
        ..on \rendered ,    Vus.init
        ..on \saved    ,    Si.signin
        ..on \validated, -> Vus.toggle-please-wait true
      ..user-signout
        ..on \rendered ,    Si.signout
      ..user-signup
        ..on \cancelled, -> Bh.history.back!
        ..on \saved    , -> R.navigate "user/#{it.id}"

    add-sub-entity-handlers V.evidence-edit, \evi
    add-sub-entity-handlers V.note-edit    , \note

    ## helpers

    function add-sub-entity-handlers view, name
      view.on 'cancelled destroyed saved', ->
        R.navigate Bh.fragment.replace new RegExp("/#name-.*$", \g), ''

    function nav-entity-saved name, entity, is-new
      function nav path = '' then R.navigate "#name/#{entity.id}#path"
      return nav! unless is-new
      <- Vev.create entity.id
      return nav if it?ok then '' else '/evi-new'
