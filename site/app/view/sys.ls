B = require \backbone
F = require \fs # inlined by brfs
A = require \../api
H = require \../helper
S = require \../sys

module.exports = B.View.extend do
  initialize: ->
    @t = F.readFileSync __dirname + \/sys.html

  render: ->
    ($t = $ @t).render S.toJSON-T!
    @$el.html $t .show!
    $ \.toggle-mode .on \click, ->
      $.ajax "#{A.sys}/mode/toggle", error:H.on-err, success: -> $ \.mode .text it.mode
