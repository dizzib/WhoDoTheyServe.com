module.exports = me =
  add-user: ->
    me.handle = it unless me.users  # autologin admin signup
    (me.users ?= {})[it.handle] = it
