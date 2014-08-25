R = require \../router
S = require \../session

module.exports =
  init: ->
    $ 'legend .update' .text "Edit #{it.get \name}"
    $ \.authtype-password .remove! unless \password is it.get \auth_type
    $ \#quota_daily .prop \disabled not S.is-signed-in-admin!

  after-delete: ->
    function nav then R.navigate \users, trigger:true
    return nav! unless it.id is S.get-id!
    S.refresh nav # refresh session if user has deleted self (and signed out)
