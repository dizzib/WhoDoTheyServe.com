Ea         = require \everyauth
M-Sessions = require \./model/sessions
M-Users    = require \./model/users

const API-PATH = '/api/auth'

module.exports =
  init: ->
    Ea
      ..debug = true
      ..everymodule.findUserById (id, cb) -> cb! # define stub to avoid Everyauth error
      ..facebook
        .appId '1655165271375218'
        .appSecret '812758f66c13dd7b181b90445b8b64ec'
        .entryPath "#API-PATH/facebook"
        .callbackPath "#API-PATH/facebook/callback"
        .fields 'id,name,link'
        .findOrCreateUser (session, , , user) ->
          findOrCreateUser session, \facebook, user.id, user.name
        .handleAuthCallbackError handleAuthCallbackError
        .myHostname \http://kango.com:4000
        .redirectPath '/'
      ..github
        .appId '80e325ecea5fc7f624a8'
        .appSecret '2ea910bc3649bd39ab0740b457076866008d490e'
        .entryPath "#API-PATH/github"
        .callbackPath "#API-PATH/github/callback"
        .findOrCreateUser (session, , , user) ->
          findOrCreateUser session, \github, user.id, user.name
        .handleAuthCallbackError handleAuthCallbackError
        .myHostname \http://kango.com:4000
        .redirectPath '/#/session'
        .scope ''

## helpers

function findOrCreateUser session, auth-type, id, name
  # oauth has successfully authenticated the user
  p = Ea.everymodule.Promise!

  function signin user
    M-Sessions.signin session, user
    p.fulfill user

  M-Users.findOne login_id:id, (err, user) ->
    return p.fail err if err
    return signin user if user # user found in db!
    # user doesn't exist in db so create it before signing in
    o = { login_id:id, auth_type:auth-type, name:name }
    err, user <- (new M-Users o).save
    return p.fail err if err
    signin user

  p

function handleAuthCallbackError req, res
  log \auth-cb-error, req, res
  res.send 500, \failed # TODO: improve
