# This code must reside under /api (not /test) to allow api openauth tests to run in
# staging where /test isn't deployed.
#
# https://gist.github.com/mweibel/5219403

Passport = require \passport
Express  = require \../../server
Err      = require \../error
Router   = require \../router
OpenAuth = require \./openauth

function set-route name, opts
  l1-opts = successRedirect:"/api/auth/mock/#name/callback"
  Router.set-api-openauth \mock, "mock/#name", (l1-opts <<< opts), opts

set-route \oa1 , id:111 name:\oa1
set-route \oa2 , id:111 name:\oa2
set-route \fail, is-pass:false

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
