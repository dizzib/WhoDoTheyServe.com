Ea = require \everyauth

usersById = []

module.exports =
  init: ->
    log \ea-init
    Ea.debug = true

    Ea.everymodule.findUserById (id, cb) ->
      log \findUserById, id
      cb null, usersById[id]

    Ea.facebook
      .appId '1655165271375218'
      .appSecret '812758f66c13dd7b181b90445b8b64ec'
      .fields 'id,name,link'
      .findOrCreateUser findOrCreateUser
      .handleAuthCallbackError handleAuthCallbackError
      .myHostname \http://kango.com:4000
      .redirectPath '/'

    Ea.github
      .appId '80e325ecea5fc7f624a8'
      .appSecret '2ea910bc3649bd39ab0740b457076866008d490e'
      #.fields 'id,name,link'
      .findOrCreateUser findOrCreateUser
      .handleAuthCallbackError handleAuthCallbackError
      .myHostname \http://kango.com:4000
      .redirectPath '/'
      .scope ''

    log Ea.facebook.myHostname!

    function findOrCreateUser session, accessToken, accessTokenExtra, user
      log \findOrCreateUser
      log accessToken
      log user
      usersById[user.id] = user

    function handleAuthCallbackError req, res
      log \auth-cb-error, req, res
