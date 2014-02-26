F = require \fs # inlined by brfs
H = require \../helper
V = require \../view

H.insert-css F.readFileSync __dirname + \/footer.css

exports.init = ->
  V.footer.render!
  attach \twitter-wjs, '//platform.twitter.com/widgets.js'
  attach \facebook-jssdk, '//connect.facebook.net/en_GB/all.js#xfbml=1'

function attach id, url then
  fjs = (d = document).getElementsByTagName(\script)[0]
  return if d.getElementById id
  js = d.createElement \script
    ..id  = id
    ..src = url
  fjs.parentNode.insertBefore js, fjs
