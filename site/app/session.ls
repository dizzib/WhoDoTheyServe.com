C = require \./collection

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
