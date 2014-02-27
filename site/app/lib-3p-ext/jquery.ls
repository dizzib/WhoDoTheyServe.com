$.fn.set-access = (session) ->
  show-or-hide \.signed-in      , session.is-signed-in!
  show-or-hide \.signed-in-admin, session.is-signed-in-admin!
  show-or-hide \.signed-out     , session.is-signed-out!
  @find '.signed-in-admin input' .prop \disabled, not session.is-signed-in-admin!
  return this

  ~function show-or-hide sel, show then
    @find sel
      .addClass    (if show then \show else \hide)
      .removeClass (if show then \hide else \show)

# http://stackoverflow.com/questions/1184624/convert-form-data-to-js-object-with-jquery
$.fn.serializeObject = ->
  arrayData = @serializeArray()
  objectData = {}

  $.each arrayData, ->
    if @value?
      value = @value
    else
      value = ''

    if objectData[@name]?
      unless objectData[@name].push
        objectData[@name] = [objectData[@name]]

      objectData[@name].push value
    else
      objectData[@name] = value

  return objectData
