B = require \backbone
C = require \./collection
E = require \./entities
H = require \./helper
R = require \./router
S = require \./session

module.exports =
  signin: ->
    <- S.refresh
    E.fetch-all ok, fail

    function ok
      B.trigger \after-signin
      R.navigate \user, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      B.history.history.back!

  signout: ->
    return signout! unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success:signout

    function signout
      B.trigger \after-signout
      R.navigate \users, trigger:true
