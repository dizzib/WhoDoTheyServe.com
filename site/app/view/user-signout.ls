B = require \backbone
C = require \../collection
H = require \../helper

module.exports = B.View.extend do
  initialize: -> _.extend this, B.Events
  render: ->
    return @trigger \destroyed unless m = C.Sessions.models.0
    m.destroy error:H.on-err, success: ~> @trigger \destroyed
