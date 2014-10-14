Passport   = require \passport
P-Facebook = require \passport-facebook .Strategy
P-Github   = require \passport-github .Strategy
P-Google   = require \passport-google-oauth .OAuth2Strategy
Err        = require \../error
H          = require \../helper
M-Sessions = require \../model/sessions
M-Users    = require \../model/users

module.exports = me =
  set-config: (auth-type, strategy, client-id, client-secret, cfg-extra) ->
    cfg =
      clientID    : client-id or \CLIENT_ID
      clientSecret: client-secret or \CLIENT_SECRET
      callbackURL : "http://#{H.get-host-api!}/api/auth/#auth-type/callback"
      # In production, the callback must happen on the api-domain and not whodotheyserve.com.
      # This is because the session cookie (for signin) is on the api-domain.
    #log \oauth-cburl, cfg.callbackURL
    Passport.use new strategy cfg <<< cfg-extra, (, , profile, done) ->
      #log \cb1, auth-type, profile
      # Other profile fields: facebook:link; github:url,avatar_url; google:link,picture
      return done new Err.Authenticate 'id is empty' unless id = (p = profile).id
      return done new Err.Authenticate 'name is empty' unless name = p.displayName
      login-id = id.toString! # id might be a number
      err, user <- M-Users.findOne login_id:login-id .lean!exec
      return done err if err
      if user
        return done null, user if user.name is name
        M-Users.findOneAndUpdate { login_id:login-id }, name:name, done # name has changed
      else # user doesn't exist in db so create it
        doc = new M-Users do
          auth_type: auth-type
          login_id : login-id
          name     : name
        doc.save done

  callback: (req, res) ->
    #log \cb2, req.user, req.session
    M-Sessions.signin req
    # In production, the browser is currently pointing at the api-domain (for signin).
    # The final redirect must take the browser back to whodotheyserve.com.
    res.redirect "http://#{H.get-host-site!}/#/user"

env = process.env
Passport.serializeUser (user, done) -> done null, user._id # put into cookie
me.set-config \facebook, P-Facebook, env.OAUTH_FACEBOOK_ID, env.OAUTH_FACEBOOK_SECRET
me.set-config \github  , P-Github  , env.OAUTH_GITHUB_ID  , env.OAUTH_GITHUB_SECRET, scope:''
me.set-config \google  , P-Google  , env.OAUTH_GOOGLE_ID  , env.OAUTH_GOOGLE_SECRET, scope:'profile'
