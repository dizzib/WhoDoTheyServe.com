# persist key to local storage
const LS-KEY = \theme

# items get *prepended* so will appear in reverse order!
const THEMES =
  dark:
    \/theme/dark.css
    \/lib-3p/theme/darkstrap.css
  light:
    \/theme/light.css
    ...

module.exports = me =
  init: ->
    me.switch-theme (localStorage?getItem(LS-KEY) or \dark)

  switch-theme: ->
    $ \link.theme .remove!
    for path in THEMES[it]
      $el = $ \<link>
        .attr \class, \theme
        .attr \href , path
        .attr \rel  , \stylesheet
        .attr \type , \text/css
      # prepending to body rather than appending to head ensures this theme's css comes after
      # any other css which subsequently gets appended to head
      $ document.body .prepend $el
    localStorage?setItem LS-KEY, it
