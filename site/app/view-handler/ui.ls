B = require \backbone
_ = require \underscore

const KEYCODE-ESC = 27
var spinner-timeout # to prevent unsightly flash when render happens quickly

$ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!

## initialisation
B.on \boot ->
  $.fn.bootstrapDropdownHover!

## routing
B.on \pre-route ->
  $ '.view' .off \focus, 'input[type=text]' .removeClass \ready
  # handle view persistance -- some views (e.g. map) should not be cleared down, for performance
  $ '.view>:not(.persist-once)' .hide!
  $ '.view>:not(.persist-once,.persist)' .off! # so different views can use same element
  $ '.view>:not(.persist-once,.persist)' .empty! # leave persistent views e.g. map
  $ '.view>.persist-once' .removeClass \persist-once
  # handle errors
  $ '.alert-error' .removeClass \active    # clear any error alert location overrides
  $ '.view>.alert-error' .addClass \active # reset back to default
  spinner-timeout := setTimeout (-> $ \.spinner .show!), 50ms

B.on \routed ->
  <- _.defer
  $ \.view .addClass \ready # signal for seo crawler
  $ \.timeago .timeago!
  clearTimeout spinner-timeout
  $ \.spinner .hide!
  <- _.defer # must come after navbar focus
  $ 'input[type=text],textarea,select,.btn-new' .filter \:visible:first .focus!

## session
B.on \signed-in-by-user  -> show-alert-once 'Welcome! You are now logged in'
B.on \signed-out-by-user -> show-alert-once 'Goodbye! You are now logged out'
B.on \signed-out-by-session-expired -> show-error 'Your session has expired. Please login again to continue.'

## error handling
B.on \error -> show-error it
B.on \validation-error -> show-error "One or more fields have errors. Please correct them before retrying."

## helpers

function show-alert-once msg
  $ '.view>.alert-info' .addClass \persist-once .text msg .show!

function show-error
  # The .active class can be used to override the default error alert location
  msg = it or 'An error occurred (check the debug console for more details)'
  $ \.alert-error.active:last .text msg .show!
