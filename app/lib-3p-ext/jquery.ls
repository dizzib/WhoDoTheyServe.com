# patch show/hide to tag hidden elements for zombie tests
# https://github.com/assaf/zombie/issues/429
$.fn.show = ->
  @removeClass \hidden
  @show ...

$.fn.hide = ->
  @addClass \hidden
  @hide ...
