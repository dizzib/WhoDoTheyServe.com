Ea         = require \everyauth
M-Sessions = require \./model/sessions
M-Users    = require \./model/users

module.exports =
  init: ->
    env = process.env
    setup \facebook, env.OAUTH_FACEBOOK_ID, env.OAUTH_FACEBOOK_SECRET
    setup \github  , env.OAUTH_GITHUB_ID  , env.OAUTH_GITHUB_SECRET
    Ea
      ..debug = true
      ..everymodule.findUserById (id, cb) -> cb! # define stub to avoid Everyauth error
      # module specific config
      ..facebook
        .fields 'id,name,link'
      ..github
        .scope ''

    function setup ea-id, oa-id, oa-secret
      Ea[ea-id] # module common config
        .appId oa-id
        .appSecret oa-secret
        .entryPath "/api/auth/#ea-id"
        .callbackPath "/api/auth/#ea-id/callback"
        .findOrCreateUser (session, , , oa-user) -> # oauth has successfully authenticated the user
          p = Ea.everymodule.Promise!

          function signin user
            M-Sessions.signin session, user
            p.fulfill user

          login-id = oa-user.id.toString! # oa-user.id might be a number
          M-Users.findOne login_id:login-id .lean!exec (err, user) ->
            return p.fail err if err
            if user
              return signin user if user.name is oa-user.name
              #log 'oauth name changed', user.name, oa-user.name
              err, user <- M-Users.findOneAndUpdate { login_id:login-id }, name:oa-user.name
              return p.fail err if err
              signin user
            else # user doesn't exist in db so create it before signing in
              o = { login_id:login-id, auth_type:ea-id, name:oa-user.name }
              err, user <- (new M-Users o).save
              return p.fail err if err
              signin user
          p
        .handleAuthCallbackError (req, res) -> res.send 500, 'openauth authentication failed'
        .myHostname "#{env.OAUTH_HOSTNAME}:#{env.PORT || 80}"
        .redirectPath '/#/session'
