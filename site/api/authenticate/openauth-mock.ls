# This code must reside under /api (not /test) to allow api openauth tests to run in
# staging where /test isn't deployed.
#
# https://gist.github.com/mweibel/5219403

Express  = require \express
Passport = require \passport
Err      = require \../error
Router   = require \./router
OpenAuth = require \./openauth

class StrategyMock extends Passport.Strategy
  (options, @verify) -> @name = \mock

  authenticate: (req, opts) ->
    opts = { is-pass:true } <<< opts
    if opts.is-pass
      oa-user = id:opts.id, displayName:opts.name
      @verify void, void, oa-user, (err, user) ~> if err then throw err else @success user
    else
      throw new Err.Authenticate \FAIL

OpenAuth.set-config \mock, StrategyMock

module.exports =
  create-router: ->
    function set-route name, opts
      l1-opts = successRedirect:"/api/auth/mock/#name/callback"
      Router.create \mock, "mock/#name", (l1-opts <<< opts), opts

    Express.Router!
      ..use set-route \oa1 , id:111 name:\oa1
      ..use set-route \oa2 , id:111 name:\oa2
      ..use set-route \fail, is-pass:false
