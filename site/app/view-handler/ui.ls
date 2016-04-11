B  = require \backbone
_  = require \underscore
Br = require \../lib/browser

const KEYCODE-ESC = 27

$ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!

## initialisation
B.on \boot ->
  $.fn.bootstrapDropdownHover!

## routing
B.on \pre-route (name) ->
  # scroll-to home must happen first, otherwise it intermittently fails with a
  # blank screen on Android Firefox.
  # Note that maps handle their own scrolling.
  Br.scroll-to x:0 y:0 unless name is \map

  $ \.view
    .off \focus 'input[type=text]'
    .children!
      .trigger \hide .hide!
      .not \.persist .off! .empty! # persistent views (eg. map) should not be cleared
  # handle errors
  $ \.alert-error .removeClass \active    # clear any error alert location overrides
  $ \.view>.alert-error .addClass \active # reset back to default

B.on \routed (name) ->
  <- _.defer # must come after navbar focus
  $ \.timeago .timeago!
  $ 'input[type=text],textarea,select,.btn-new' .filter \:visible:first .focus!

## session
B.on \signed-in-by-user  -> show-alert 'Welcome! You are now logged in'
B.on \signed-out-by-user -> show-alert 'Goodbye! You are now logged out'
B.on \signed-out-by-session-expired -> show-error 'Your session has expired. Please login again to continue.'

## error handling
B.on \error -> show-error it
B.on \validation-error -> show-error "One or more fields have errors. Please correct them before retrying."

## helpers

function show-alert msg then $ \.view>.alert-info .text msg .show!

function show-error
  # The .active class can be used to override the default error alert location
  msg = it or 'An error occurred (check the debug console for more details)'
  $ \.alert-error.active:last .text msg .show!
