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
    const MSG = 'An error occurred (check the debug console for more details)'
    return me.show-error MSG unless xhr.status
    return me.show-error 'Please login' if xhr.status is 401
    me.show-error xhr.responseText

  show-error: ->
    # The .active class can be used to override the default error alert location
    $ \.alert-error.active:last .text it .show!
