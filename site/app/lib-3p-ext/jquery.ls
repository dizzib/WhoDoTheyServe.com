$.fn.disable-buttons = ->
  @find \.btn .prop \disabled true .addClass \disabled

$.fn.enable-buttons = ->
  @find \.btn .prop \disabled false .removeClass \disabled

_hide = $.fn.hide
$.fn.hide = (speed, cb) ->
  $ this .trigger \hide
  _hide.apply this, arguments

$.fn.set-access = (session) ->
  show-or-hide \.signed-in       session.is-signed-in!
  show-or-hide \.signed-in-admin session.is-signed-in-admin!
  show-or-hide \.signed-out      session.is-signed-out!
  @find '.signed-in-admin input' .prop \disabled not session.is-signed-in-admin!
  return @

  ~function show-or-hide sel, show
    @find sel
      .addClass    (if show then \show else \hide)
      .removeClass (if show then \hide else \show)

# http://stackoverflow.com/questions/1184624/convert-form-data-to-js-object-with-jquery
$.fn.serializeObject = ->
  function set name, val, to-array = true
    const IGNORE-NAME = /^select(Item|Allnodes)/ # jquery.multi.select
    return if IGNORE-NAME.test name
    path = name.split \. # name can be 'foo.bar.baz'
    o = if path.length is 1 then res else path[til -1].reduce ((r, k) -> r[k] or r[k] = {}), res
    k = path[*-1]
    v = if typeof val is \boolean then val else val or ''
    if to-array and o[k]?
      o[k] = [o[k]] unless o[k].push
      o[k].push v
    else
      o[k] = v
  res = {}
  for {name, value} in @serializeArray! then set name, value
  # http://stackoverflow.com/questions/3029870/jquery-serialize-does-not-register-checkboxes
  for c in @find 'input[type=checkbox]:visible' then set c.name, c.checked, false
  res
