B = require \backbone
F = require \fs
C = require \../collection
H = require \../helper
S = require \../session

T = F.readFileSync __dirname + \/news.html

module.exports = B.View.extend do
  render: ->
    $t = $ T
    @$el.html $t .show!
