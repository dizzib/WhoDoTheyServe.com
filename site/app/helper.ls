inserted-css = []

module.exports = me =
  # based on https://github.com/substack/insert-css
  # used by inline brfs so cannot use jquery
  insert-css: ->
    return
    return if (inserted-css.indexOf it) >= 0
    inserted-css.push it

    el = document.createElement \style
    el.setAttribute 'type', 'text/css'
    el.appendChild document.createTextNode it
    document.head.appendChild el
    el

  insert-css-seo: ->
    return
    el = me.insert-css it
    el.setAttribute 'data-seo-emit', ''
