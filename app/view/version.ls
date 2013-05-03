B = require \backbone
H = require \../helper
M = require \../model

module.exports = B.View.extend do
  render: ->
    return @render-el @sys-json if @sys-json
    new M.Sys!fetch do
      error  : H.on-err
      success: ~> @render-el @sys-json = it.toJSON-T!
  render-el: -> @$el.text "v#{it.version}"
