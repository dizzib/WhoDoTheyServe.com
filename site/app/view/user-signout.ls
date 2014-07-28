B = require \backbone
C = require \../collection
H = require \../helper
R = require \../router
V = require \../view

module.exports = B.View.extend do
  initialize: ->
    _.extend this, B.Events

  render: ->
    return signout! unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success:signout

    function signout
      delete V.map.map # remove editing map
      R.navigate \session, trigger:true
