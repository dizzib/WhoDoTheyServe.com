Bh  = require \backbone .history
C   = require \./collection
R   = require \./router
S   = require \./session
V   = require \./view
Ve  = require \./view-engine
Vee = require \./view/edge-edit
Vev = require \./view/evidence
Vue = require \./view/user-edit
Vus = require \./view/user-signin

const KEYCODE-ESC = 27

module.exports =
  init: ->
    $ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!
    V
      ..edge-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, -> navigate \edges
        ..on \rendered ,    Vee.init
        ..on \saved    , -> nav-entity-saved \edge, &0, &1
      ..evidence-edit
        ..on \cancelled, -> nav-extra-done \evi
        ..on \destroyed, -> nav-extra-done \evi
        ..on \rendered ,    Vev.init
        ..on \saved    , -> nav-extra-done \evi
      ..node-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, -> navigate \nodes
        ..on \rendered , -> $ \#name .typeahead source:C.Nodes.pluck \name
        ..on \saved    , -> nav-entity-saved \node, &0, &1
      ..note-edit
        ..on \cancelled, -> nav-extra-done \note
        ..on \destroyed, -> nav-extra-done \note
        ..on \saved    , -> nav-extra-done \note
      ..user-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed,    Vue.after-delete
        ..on \rendered ,    Vue.init
        ..on \saved    , -> navigate "user/#{it.id}"
      ..user-signin
        ..on \cancelled, -> Bh.history.back!
        ..on \error    , -> Vus.toggle-please-wait false
        ..on \rendered ,    Vus.init
        ..on \saved    ,    Vus.on-signin
      ..user-signup
        ..on \cancelled, -> Bh.history.back!
        ..on \saved    , -> navigate "user/#{it.id}"

    # helpers

    function navigate then R.navigate it, trigger:true

    function nav-entity-saved name, entity, is-new
      return nav! unless is-new
      function nav path = '' then navigate "#name/#{entity.id}#path"
      <- Vev.create entity.id
      return nav if it?ok then '' else '/evi-new'

    function nav-extra-done name
      navigate Bh.fragment.replace new RegExp("/#name-.*$", \g), ''
