B   = require \backbone
R   = require \./router
V   = require \./view
Vae = require \./view-activity/edit
Vui = require \./view-handler/ui

module.exports =
  init: ->
    _invalid = B.Validation.callbacks.invalid
    B
      ..Model.prototype.idAttribute = \_id # mongodb
      ..Validation
        ..configure labelFormatter:\label
        ..callbacks.invalid = ->
          _invalid ...
          Vui.show-error "One or more fields have errors. Please correct them before retrying."
      ..tracker = edge:void, node-ids:[] # keep track of last edited entities

      ..on \after-signin-by-user, ->
        Vui.show-alert-once 'Welcome! You are now logged in'
        R.navigate \user
      ..on \after-signout-by-session-expired, ->
        Vui.show-error 'Your session has expired. Please login again to continue.'
      ..on \after-signout-by-user, ->
        Vui.show-alert-once 'Goodbye! You are now logged out'
        R.navigate \users
      ..on 'route-before', ->
        Vui.reset!
      ..on 'route-after', ->
        Vae.ResetEditView!
        Vui.finalise!
        V.navbar.render!
      ..on 'signin signout', ->
        V.map.delete!
