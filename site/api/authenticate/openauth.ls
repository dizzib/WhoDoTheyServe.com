Passport   = require \passport
P-Facebook = require \passport-facebook .Strategy
P-Github   = require \passport-github .Strategy
P-Google   = require \passport-google-oauth .OAuth2Strategy
H          = require \../helper
M-Sessions = require \../model/sessions
M-Users    = require \../model/users

env = process.env
module.exports = me =
  init: ->
    Passport.serializeUser (user, done) -> done null, user._id # put into cookie
    me.set-config \facebook, P-Facebook, env.OAUTH_FACEBOOK_ID, env.OAUTH_FACEBOOK_SECRET
    me.set-config \github  , P-Github  , env.OAUTH_GITHUB_ID  , env.OAUTH_GITHUB_SECRET, scope:''
    me.set-config \google  , P-Google  , env.OAUTH_GOOGLE_ID  , env.OAUTH_GOOGLE_SECRET, scope:'profile'

  set-config: (auth-type, strategy, client-id, client-secret, cfg-extra) ->
    cfg =
      clientID    : client-id
      clientSecret: client-secret
      callbackURL : "http://#{env.SITE_DOMAIN_NAME}:#{env.PORT || 80}/api/auth/#auth-type/callback"
    Passport.use new strategy cfg <<< cfg-extra, (, , profile, done) ->
      #log auth-type, profile
      # Other profile fields: facebook:link; github:url,avatar_url; google:link,picture
      return done new H.AuthenticateError 'id is empty' unless lid = (p = profile)?id.toString! # id might be a number
      return done new H.AuthenticateError 'name is empty' unless name = p.displayName
      err, user <- M-Users.findOne login_id:lid .lean!exec
      return done err if err
      if user
        return done null, user if user.name is name
        M-Users.findOneAndUpdate { login_id:lid }, name:name, done # name has changed
      else # user doesn't exist in db so create it
        (new M-Users { login_id:lid, auth_type:auth-type, name:name }).save done

  callback: (req, res) ->
    #log \callback, req.user, req.session
    M-Sessions.signin req
    res.redirect '/#/user'
