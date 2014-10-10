B  = require \backbone
C  = require \./collection
Cs = require \./collections
H  = require \./helper

module.exports = me =
  auto-sync-el: ($el) ->
    C.Sessions.on \sync, -> $el.set-access me
    $el.set-access me

  get-id: ->
    C.Sessions.models.0?id

  is-signed-in: ->
    return C.Sessions.length > 0 unless it
    return me.get-id! is it

  is-signed-in-admin: ->
    \admin is C.Sessions.models.0?get \role

  is-signed-out: ->
    C.Sessions.length is 0

  refresh: (cb) ->
    C.Sessions.fetch error:H.on-err, success:cb

  signin: ->
    <- me.refresh
    Cs.fetch-all ok, fail

    function ok
      B.trigger \signin
      B.trigger \after-signin

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      B.history.history.back!

  signout: ->
    return signout! unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success:signout

    function signout
      B.trigger \signout
      B.trigger \after-signout
