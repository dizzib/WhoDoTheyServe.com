# items get *prepended* so will appear in reverse order!
const THEMES =
  default:
    \/theme/default.css
    ...
  dark:
    \/theme/dark.css
    \/lib-3p/theme/darkstrap.css

module.exports = me =
  switch-theme: ->
    $ \link.theme .remove!
    for path in THEMES[it]
      log path
      $el = $ \<link>
        .attr \class, \theme
        .attr \href , path
        .attr \rel  , \stylesheet
        .attr \type , \text/css
      # prepending to body rather than appending to head ensures this theme's css comes after
      # any other css which subsequently gets appended to head
      $ document.body .prepend $el
