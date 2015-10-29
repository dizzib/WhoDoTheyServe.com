# a javascript timer uses much less cpu than css animations
module.exports = (vg, cursor) ->
  const N-FRAMES = 5

  var timer
  frame = 0
  vg.$el.addClass \frame-0

  function advance-frame
    vg.$el.toggleClass "frame-#frame"
    frame := ++frame % N-FRAMES
    vg.$el.toggleClass "frame-#frame"

  cursor.on \hide -> clearInterval timer
  cursor.on \show -> timer := setInterval advance-frame, 500ms
