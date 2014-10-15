B   = require \backbone
_   = require \underscore
R   = require \./router
V   = require \./view
Vae = require \./view-activity/edit
Vui = require \./view-handler/ui

module.exports =
  init: ->
    B.Model.prototype.idAttribute = \_id # mongodb
    B.tracker = edge:void, node-ids:[] # keep track of last edited entities

    # standard error handler
    _sync = B.sync
    B.sync = (method, model, options) ->
      error = options.error
      options.error = (coll, xhr) ->
        (error ...) if error
        return S.expire! if xhr?status is 401
        Vui.show-error xhr?responseText
      _sync method, model, options

    # validation
    _invalid = B.Validation.callbacks.invalid
    B.Validation
      ..configure labelFormatter:\label
      ..callbacks.invalid = ->
        _invalid ...
        Vui.show-error "One or more fields have errors. Please correct them before retrying."

    B # event handlers
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
