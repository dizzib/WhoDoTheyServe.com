Bh  = require \backbone .history
C   = require \./collection
E   = require \./entities
H   = require \./helper
R   = require \./router
S   = require \./session
V   = require \./view
Vme = require \./view/map/edit

module.exports = me =
  after-signin: ->
    H.show-alert-once 'Welcome! You are now logged in'
    Vme.init!

  signin: ->
    <- S.refresh
    E.fetch ok, fail

    function ok
      clear-active-map!
      me.after-signin!
      R.navigate \user, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      B.history.history.back!

  signout: ->
    return signout! unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success:signout

    function signout
      H.show-alert-once 'Goodbye! You are now logged out'
      clear-active-map!
      R.navigate \users, trigger:true

## helpers

function clear-active-map
  delete V.map.map
