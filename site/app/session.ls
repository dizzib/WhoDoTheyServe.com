B  = require \backbone
C  = require \./collection
Cs = require \./collections

B.on \boot ->
  C.Sessions.on \sync set-access
  set-access!

module.exports = me =
  get-id: -> C.Sessions.models.0?id

  expire: ->
    C.Sessions.reset!
    set-access!
    B.trigger \signout
    B.trigger \signed-out-by-session-expired

  is-signed-in      : -> if it then me.get-id! is it else C.Sessions?length > 0
  is-signed-in-admin: -> \admin is C.Sessions.models.0?get \role
  is-signed-out     : -> C.Sessions.length is 0

  refresh: (cb) -> C.Sessions.fetch success:cb

  signin: ->
    <- me.refresh
    Cs.fetch-all ok, fail

    function ok
      C.Maps.fetch success: ->
        B.trigger \signin
        B.trigger \signed-in-by-user

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      B.history.history.back!

  signout: ->
    return unless m = C.Sessions.models.0
    m.destroy success: ->
      set-access!
      C.Maps.fetch success: ->
        B.trigger \signout
        B.trigger \signed-out-by-user

function set-access
  $ \body
    ..toggleClass \signed-in me.is-signed-in!
    ..toggleClass \signed-in-admin me.is-signed-in-admin!
