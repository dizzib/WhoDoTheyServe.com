B = require \backbone
C = require \./collection
H = require \./helper

B.on \after-signin, -> # can be triggered from boot
  H.show-alert-once 'Welcome! You are now logged in'

B.on \after-signout, ->
  H.show-alert-once 'Goodbye! You are now logged out'

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
