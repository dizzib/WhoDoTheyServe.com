# https://gist.github.com/mweibel/5219403

Passport = require \passport
H        = require \../helper
OpenAuth = require \./openauth

module.exports =
  init: ->
    class StrategyMock extends Passport.Strategy
      (options, verify) ->
        @name      = \mock
        @is-pass   = options.is-pass or true
        @user-id   = options.user-id or 1234123
        @user-name = options.user-name or \oa1
        @verify    = verify

      authenticate: ->
        if @is-pass
          oa-user = id:@user-id, displayName:@user-name
          @verify void, void, oa-user, (err, user) ~> if err then throw err else @success user
        else
          throw new H.AuthenticateError \FAIL

    OpenAuth.set-config \mock, StrategyMock
