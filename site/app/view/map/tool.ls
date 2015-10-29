module.exports =
  init: (v-map) ->
    ($map = v-map.$el).find \.tools .on \click \legend ->
      $tool = $ this .parents \.tool .toggleClass \collapsed
      return unless has-store-key $tool
      localStorage.setItem (get-store-key $tool), $tool.hasClass \collapsed

    v-map.v-info.on \rendered restore-state
    v-map.v-layers.on \rendered restore-state

function get-store-key $tool then "#{$tool.attr \data-state-key}/collapsed"
function has-store-key $tool then $tool.attr \data-state-key

function restore-state
  @$el.toggleClass \collapsed (\true is localStorage.getItem get-store-key @$el)
