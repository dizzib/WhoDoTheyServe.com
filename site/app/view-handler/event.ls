Bh  = require \backbone .history
C   = require \../collection
R   = require \../router
Si  = require \../signin
V   = require \../view
Vee = require \../view/edge/edit
Vev = require \../view/evidence
Vue = require \../view/user/edit
Vus = require \../view/user/signin

module.exports =
  init: ->
    V
      ..edge-edit
        ..on \rendered, Vee.init
      ..evidence-edit
        ..on \rendered, Vev.init
      ..map-edit
        ..on \destroyed, -> R.navigate \user
        ..on \saved    , (map, is-new) -> R.navigate "map/#{map.id}" if is-new
      ..node-edit
        ..on \rendered, -> $ \#name .typeahead source:C.Nodes.pluck \name
      ..user-edit
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, Vue.after-delete
        ..on \rendered , Vue.init
        ..on \saved    , -> R.navigate "user/#{it.id}"
      ..user-signin
        ..on \cancelled, -> Bh.history.back!
        ..on \error    , -> Vus.toggle-please-wait false
        ..on \rendered , Vus.init
        ..on \saved    , Si.signin
        ..on \validated, -> Vus.toggle-please-wait true
      ..user-signout
        ..on \rendered, Si.signout
      ..user-signup
        ..on \cancelled, -> Bh.history.back!
        ..on \saved    , -> R.navigate "user/#{it.id}"

    add-entity-handlers V.edge-edit, \edge
    add-entity-handlers V.node-edit, \node
    add-sub-entity-handlers V.evidence-edit, \evi
    add-sub-entity-handlers V.note-edit    , \note

    ## helpers

    function add-entity-handlers view, name
      view
        ..on \cancelled, -> Bh.history.back!
        ..on \destroyed, -> R.navigate "#{name}s"
        ..on \saved, (o, is-new) ->
          function nav path = '' then R.navigate "#name/#{o.id}#path"
          return nav! unless is-new
          <- Vev.create o.id
          return nav if it?ok then '' else '/evi-new'

    function add-sub-entity-handlers view, name
      view.on 'cancelled destroyed saved', ->
        R.navigate Bh.fragment.replace new RegExp("/#name-.*$", \g), ''
