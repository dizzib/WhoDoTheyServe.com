$.fn.set-access = (session) ->
  show-or-hide \.signed-in      , session.is-signed-in!
  show-or-hide \.signed-in-admin, session.is-signed-in-admin!
  show-or-hide \.signed-out     , session.is-signed-out!
  @find '.signed-in-admin input' .prop \disabled, not session.is-signed-in-admin!
  return @

  ~function show-or-hide sel, show then
    @find sel
      .addClass    (if show then \show else \hide)
      .removeClass (if show then \hide else \show)

# http://stackoverflow.com/questions/1184624/convert-form-data-to-js-object-with-jquery
$.fn.serializeObject = ->
  const IGNORE-NAME = /^select(Item|Allnodes)/ # jquery.multi.select
  a = @serializeArray!
  o = {}
  $.each a, ->
    unless IGNORE-NAME.test @name
      value = if @value? then @value else ''
      if o[@name]?
        o[@name] = [o[@name]] unless o[@name].push
        o[@name].push value
      else
        o[@name] = value
  o
