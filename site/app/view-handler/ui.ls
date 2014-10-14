_  = require \underscore
V  = require \../view
Ve = require \../view-activity/edit

const KEYCODE-ESC = 27

$ document .keyup -> if it.keyCode is KEYCODE-ESC then $ \.cancel .click!

module.exports =
  finalise: ->
    # use a delgated event since view may still be rendering asyncly
    $ \.view .on \focus, 'input[type=text]', ->
      # defer, to workaround Chrome mouseup bug
      # http://stackoverflow.com/questions/2939122/problem-with-chrome-form-handling-input-onfocus-this-select
      _.defer ~> @select!
    <- _.defer
    $ \.btn-new:visible:first .focus!
    $ \.view .addClass \ready
    $ \.timeago .timeago!

  reset: ->
    $ '.view' .off \focus, 'input[type=text]' .removeClass \ready

    # handle view persistance -- some views (e.g. map) should not be cleared down, for performance
    $ '.view>:not(.persist-once)' .hide!
    $ '.view>:not(.persist-once,.persist)' .off! # so different views can use same element
    $ '.view>:not(.persist-once,.persist)' .empty! # leave persistent views e.g. map
    $ '.view>.persist-once' .removeClass \persist-once

    # handle errors
    $ '.alert-error' .removeClass \active    # clear any error alert location overrides
    $ '.view>.alert-error' .addClass \active # reset back to default

    V.navbar.render!
    Ve.ResetEditView!

  show-alert-once: (msg) ->
    $ '.view>.alert-info' .addClass \persist-once .text msg .show!
