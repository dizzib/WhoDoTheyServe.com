B = require \backbone

B.on \boot, ->
  # Load 'extras' such as overlays here. Note the core map does not depend on any of these.
  # Event handlers fire in the same order these files are required (neat Backbone feature!).
  # This is especially important for most render handlers since svg uses painter's algo.
  require \./cluster
  require \./overlay/slit
  require \./edge-glyph
  require \./overlay
  require \./overlay/bil
  require \./pin
  #require \./cursor
