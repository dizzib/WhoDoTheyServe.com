inserted-css = []

module.exports = me =
  # based on https://github.com/substack/insert-css
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
    const MSG = 'An error occurred (check the debug console for more details)'
    me.show-error xhr.responseText || MSG

  post-json: (url, obj) ->
    new XMLHttpRequest!
      ..open \POST, url
      ..setRequestHeader 'Content-Type', 'application/json; charset=UTF-8'
      ..send JSON.stringify obj

  show-error: ->
    $ \.alert-error .text it .show!
