module.exports.init = ->
  $ 'legend .update' .text "Edit #{it.get \name}"
  $ \.authtype-password .remove! unless \password is it.get \auth_type
