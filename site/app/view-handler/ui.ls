B = require \backbone
_ = require \underscore

const KEYCODE-ESC = 27

$ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!

B.on \pre-route, ->
  $ '.view' .off \focus, 'input[type=text]' .removeClass \ready
  # handle view persistance -- some views (e.g. map) should not be cleared down, for performance
  $ '.view>:not(.persist-once)' .hide!
  $ '.view>:not(.persist-once,.persist)' .off! # so different views can use same element
  $ '.view>:not(.persist-once,.persist)' .empty! # leave persistent views e.g. map
  $ '.view>.persist-once' .removeClass \persist-once
  # handle errors
  $ '.alert-error' .removeClass \active    # clear any error alert location overrides
  $ '.view>.alert-error' .addClass \active # reset back to default

B.on \routed, ->
  # use a delgated event since view may still be rendering asyncly
  $ \.view .on \focus, 'input[type=text]', ->
    # defer, to workaround Chrome mouseup bug
    # http://stackoverflow.com/questions/2939122/problem-with-chrome-form-handling-input-onfocus-this-select
    _.defer ~> @select!
  <- _.defer
  $ \.btn-new:visible:first .focus!
  $ \.view .addClass \ready # signal for seo crawler
  $ \.timeago .timeago!

B.on \signed-in-by-user, ->
  show-alert-once 'Welcome! You are now logged in'
B.on \signed-out-by-user, ->
  show-alert-once 'Goodbye! You are now logged out'
B.on \signed-out-by-session-expired, ->
  me.show-error 'Your session has expired. Please login again to continue.'

module.exports = me =
  show-error: ->
    # The .active class can be used to override the default error alert location
    msg = it or 'An error occurred (check the debug console for more details)'
    $ \.alert-error.active:last .text msg .show!

## helpers

function show-alert-once msg
  $ '.view>.alert-info' .addClass \persist-once .text msg .show!
