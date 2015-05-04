Express  = require \express
Passport = require \passport
OpenAuth = require \./openauth
SecSess  = require \../security/sessions

module.exports = # used by openauth-mock
  create: (auth-type, path = auth-type, l1-opts = {}, l2-opts = {}) ->
    const L2-OPTS = failureRedirect:'/#/user/signin/error'
    Express.Router!
      ..get "/#path"         , SecSess.before-authenticate
      ..get "/#path"         , Passport.authenticate auth-type, l1-opts
      ..get "/#path/callback", Passport.authenticate auth-type, L2-OPTS <<< l2-opts
      ..get "/#path/callback", SecSess.after-authenticate
      ..get "/#path/callback", OpenAuth.callback
