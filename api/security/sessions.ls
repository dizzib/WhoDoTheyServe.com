_        = require \underscore
CryptPwd = require \../crypt-pwd
H        = require \../helper
Users    = require \../model/users

exports
  ..create = ->
    (req, res, next) ->
      freeze-secs = process.env.WDTS_USER_SIGNIN_BAD_FREEZE_SECS or 5s
      do
        err, user <- Users.findOne login:(b = req.body).login
        return next err if err
        return fail next unless user
        if process.env.WDTS_USER_SIGNIN_ENABLE is \false
        and user.role is \user then return next new H.ApiError do
          "User logins are currently disabled. Please contact admin for more info."
        if d = user.freeze_until then
          if Date.now! < new Date d then return next new H.ApiError do
            "Account is temporarily frozen. Please retry in #{freeze-secs} seconds"
        err, is-match <- CryptPwd.check b.password, user.password
        return next err if err
        return fail next, user unless is-match
        #return next new Error 'user not verified' unless user.is_verified
        user.freeze_until = void
        err, req.user <- user.save
        next err

      function fail next, user then
        do
          return reply! unless user and freeze-secs > 0
          d = new Date!
          d.setSeconds d.getSeconds! + freeze-secs
          user.freeze_until = d
          err, user <- user.save
          return next err if err
          reply!

        function reply then next new H.ApiError do
          "Login failed! Please ensure your username and password are correct."

  ..delete = ->
    (req, res, next) ->
      return next new Error 'signin required' unless si = req.session.signin
      return next new Error 'signin mismatch' unless req.id is si.id
      next!
