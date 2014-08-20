Bh  = require \backbone .history
C   = require \../collection
E   = require \../entities
H   = require \../helper
Hi  = require \../hive
R   = require \../router
S   = require \../session
V   = require \../view
Vme = require \./map/edit

module.exports = me =
  init: ->
    $ '.openauth a, .btn-primary' .click -> me.toggle-please-wait true
    $ '.btn-primary span' .text \Login
    $ '.btn-primary i' .addClass \fa-sign-in

  init-signin: ->
    H.show-alert-once 'Welcome! You are now logged in'
    Vme.init!
    # multi-select can't be browserified 'cos it references an adjacent png
    yepnope.injectCss \/lib-3p/multiple-select.css

  on-signin: ->
    <- S.refresh
    E.fetch ok, fail

    function ok
      delete V.map.map # remove readonly map
      me.init-signin!
      R.navigate \user, trigger:true

    function fail coll, xhr
      alert "Unable to load entities.\n\n#{xhr.responseText}"
      Bh.history.back!

  toggle-please-wait: ->
    $ \.please-wait .toggle it
    $ 'form, .openauth' .toggle not it
