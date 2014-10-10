B  = require \backbone
C  = require \./collection
Cs = require \./collections
H  = require \./helper
R  = require \./router
S  = require \./session

module.exports =
  signin: ->
    <- S.refresh
    Cs.fetch-all ok, fail

    function ok
      B.trigger \signin
      R.navigate \user

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      B.history.history.back!

  signout: ->
    return signout! unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success:signout

    function signout
      B.trigger \signout
      R.navigate \users
