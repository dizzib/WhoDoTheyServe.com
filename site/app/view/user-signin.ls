module.exports = me =
  init: ->
    $ '.openauth a, .btn-primary' .click -> me.toggle-please-wait true
    $ '.btn-primary span' .text \Login
    $ '.btn-primary i' .addClass \fa-sign-in

  toggle-please-wait: ->
    $ \.please-wait .toggle it
    $ 'form, .openauth' .toggle not it
