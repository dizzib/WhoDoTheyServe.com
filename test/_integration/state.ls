module.exports = M =
  add-user: ->
    M.login = it unless M.users  # autologin admin signup
    (M.users ?= {})[it.login] = it
