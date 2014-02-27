B = require \backbone
H = require \../helper
M = require \../model

module.exports = B.View.extend do
  render: -> @$el.text "v#{M.Sys.get \version}"
