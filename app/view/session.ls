B = require \backbone
F = require \fs
C = require \../collection
H = require \../helper

T = F.readFileSync __dirname + \/session.html

module.exports = B.View.extend do
  render: ->
    C.Sessions.fetch error:H.on-err, success:render
    ~function render then
      @$el.html T .set-access!show!
