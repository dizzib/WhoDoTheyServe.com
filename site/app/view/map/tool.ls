module.exports = (v-map) ->
  ($map = v-map.$el).find \.tools
    ..on 'click' \legend toggle
    ..on \mouseenter '.collapsed legend' toggle

  v-map.on \show ->
    restore-state v-map.v-info
    restore-state v-map.v-layers

function get-store-key $tool then "#{$tool.attr \data-state-key}/collapsed"
function has-store-key $tool then $tool.attr \data-state-key

function restore-state
  it.$el.toggleClass \collapsed (\true is localStorage.getItem get-store-key it.$el)

function toggle
  $el = $ @ .parents \.tool .toggleClass \collapsed
  $el.trigger if $el.hasClass \collapsed then \collapse else \expand
  return unless has-store-key $el
  localStorage.setItem (get-store-key $el), $el.hasClass \collapsed
