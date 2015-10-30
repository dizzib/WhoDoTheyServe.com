B   = require \backbone
Bh  = require \backbone .history
C   = require \../collection
Fpx = require \../fireprox
R   = require \../router
S   = require \../session
Sys = require \../model/sys .instance
V   = require \../view
Vee = require \../view/edge/edit
Vne = require \../view/node/edit
Vue = require \../view/user/edit
Vus = require \../view/user/signin

B.on \boot ->
  V.edge-edit
    ..on \rendered Vee.init
  V.evidence-edit
    ..on \rendered -> Fpx.get-browser-url (-> $ \#url .attr \value it) if it.isNew!
  V.maps
    ..on \cleared  -> V.navbar.render!
    ..on \deleted  -> R.navigate \user
    ..on \rendered -> V.navbar.render!
    ..on \saved (map, is-new) ->
      V.navbar.render!
      R.navigate "map/#{map.id}" if is-new
  V.node-edit
    ..on \rendered Vne.init
    ..on \saved    Vne.save
  V.user-edit
    ..on \cancelled -> Bh.history.back!
    ..on \destroyed Vue.after-delete
    ..on \rendered  Vue.init
    ..on \saved     -> R.navigate "user/#{it.id}"
  V.user-signin
    ..on \cancelled -> Bh.history.back!
    ..on \error     -> Vus.toggle-please-wait false
    ..on \rendered  Vus.init
    ..on \saved     S.signin
    ..on \validated -> Vus.toggle-please-wait true
  V.user-signout
    ..on \rendered S.signout
  V.user-signup
    ..on \cancelled -> Bh.history.back!
    ..on \saved     -> R.navigate "user/#{it.id}"

  add-entity-handlers V.edge-edit, \edge
  add-entity-handlers V.node-edit, \node
  add-sub-entity-handlers V.evidence-edit, \evi
  add-sub-entity-handlers V.note-edit, \note

  ## helpers

  function add-entity-handlers view, name
    view
      ..on \cancelled -> Bh.history.back!
      ..on \destroyed -> R.navigate "#{name}s"
      ..on \saved (o, is-new) ->
        function nav path = '' then R.navigate "#name/#{o.id}#path"
        return nav! unless is-new
        <- C.Evidences.auto-create o.id
        return nav if it?ok then '' else '/evi-new'

  function add-sub-entity-handlers view, name
    view.on 'cancelled destroyed saved' ->
      R.navigate Bh.fragment.replace new RegExp("/#name-.*$" \g), ''

Sys.on \sync -> V.version.render this
