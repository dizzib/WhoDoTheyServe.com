B  = require \backbone
_  = require \underscore
Br = require \../lib/browser

## initialisation
B.on \boot ->
  const KEYCODE-ESC = 27
  $ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!
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

B.on \routed ->
  <- _.defer # must come after navbar focus
  $ \.timeago .timeago!
  $ 'input[type=text],textarea,select,.btn-new' .filter \:visible:first .focus!
