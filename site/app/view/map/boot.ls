B = require \backbone

B.on \boot ->
  # Load 'extras' such as overlays here. Note the core map does not depend on any of these.
  # Event handlers fire in the same order these files are required (neat Backbone feature!).
  # This is especially important for render handlers relying on svg's painters algo.
  require \./overlay/slit
  require \./edge-glyph
  require \./overlay
  require \./overlay/bil/edge
  require \./overlay/bil/node
  require \./pin
  require \./region
  #require \./cursor

  frame = 0
  ($map = $ \.map).addClass \frame-0
  function advance-frame
    $map .toggleClass "frame-#frame"
    frame := ++frame % 5
    $map .toggleClass "frame-#frame"

  setInterval advance-frame, 500ms
