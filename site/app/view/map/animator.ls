# a javascript timer uses much less cpu than css animations
C = require \./cursor

const N-FRAMES = 5

var timer
frame = 0
($map = $ \.map).addClass \frame-0

function advance-frame
  $map .toggleClass "frame-#frame"
  frame := ++frame % N-FRAMES
  $map .toggleClass "frame-#frame"

C.on \hide -> clearInterval timer
C.on \show -> timer := setInterval advance-frame, 500ms
