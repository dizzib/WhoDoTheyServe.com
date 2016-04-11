B = require \backbone

const CLASS-RENDERING = \rendering # signal the seo task to block

var spinner-timeout # to prevent unsightly flash when render happens quickly
$spinner = $ \.spinner
$view    = $ \.view

module.exports = me =
  set: ($el) ->
    $el.addClass CLASS-RENDERING

  unset: ($el) ->
    $el.removeClass CLASS-RENDERING
    unless $ ".#CLASS-RENDERING" .length # all sync + async done ?
      clearTimeout spinner-timeout
      $spinner.hide!

B.on \pre-route ->
  $ ".#CLASS-RENDERING" .removeClass CLASS-RENDERING
  spinner-timeout := setTimeout (-> $spinner.show!), 50ms
  me.set $view

B.on \routed ->
  me.unset $view # async render may still be happening
