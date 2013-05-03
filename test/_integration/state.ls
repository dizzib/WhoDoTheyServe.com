exports
  ..add-user = ->
    exports.login = it unless exports.users  # autologin admin signup
    (exports.users ?= {})[it.login] = it
