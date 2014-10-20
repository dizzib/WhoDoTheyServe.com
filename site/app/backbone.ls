B   = require \backbone
R   = require \./router
Vui = require \./view-handler/ui

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
    B.trigger \validation-error

B # event handlers
  ..on \signed-in-by-user , -> R.navigate \user
  ..on \signed-out-by-user, -> R.navigate \users
