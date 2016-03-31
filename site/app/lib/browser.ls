_ = require \underscore

module.exports =
  scroll-to: (pos) ->
    is-android-firefox = /Android.+Firefox/.test navigator.userAgent
    # Without defer, scrolling intermittently fails on Android Firefox.
    # Unfortunately, this introduces some flickering.
    <- if is-android-firefox then _.defer else -> it!
    window.scrollTo pos.x, pos.y
