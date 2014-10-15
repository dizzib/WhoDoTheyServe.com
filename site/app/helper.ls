S   = require \./session
Vui = require \./view-handler/ui

inserted-css = []

module.exports = me =
  # based on https://github.com/substack/insert-css
  # used by inline brfs so cannot use jquery
  insert-css: ->
    return if (inserted-css.indexOf it) >= 0
    inserted-css.push it

    el = document.createElement \style
    el.setAttribute 'type', 'text/css'
    el.appendChild document.createTextNode it
    document.head.appendChild el
    el

  insert-css-seo: ->
    el = me.insert-css it
    el.setAttribute 'data-seo-emit', ''

  on-err: (coll, xhr) ->
    return S.expire! if xhr?status is 401
    Vui.show-error xhr?responseText || 'An error occurred (check the debug console for more details)'
