module.exports = me =
  init: ->
    $ '.openauth a' .click -> me.toggle-please-wait true
    $ '.btn-primary span' .text \Login
    $ '.btn-primary .fe' .removeClass \fe-ok .addClass \fe-login

  toggle-please-wait: ->
    $ \.please-wait .toggle it
    $ 'form, .openauth' .toggle not it
