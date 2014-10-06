H     = require \../helper
Users = require \../model/users

const DAILY_SIGNUP_MAX = 5

module.exports =
  create: (req, res, next) ->
    err, n <- Users.count
    return next err if err
    return next! if n is 0
    err, n <- Users.count 'meta.create_date': $gte:H.get-date-yesterday!
    if n >= DAILY_SIGNUP_MAX then return next new H.ApiError "
      Maximum number of signups exceeded for today. 
      Please try again in 24 hours or contact admin.
    "
    return next new Error 'signin required' unless si = req.session.signin
    return next new Error 'only admin can signup' unless si.role is \admin
    #return next new Error 'only admin can add quota_daily' if req.body.quota_daily
    next!

  maintain: (req, res, next) ->
    return next new Error 'signin required' unless si = req.session.signin
    return next! if si.role is \admin
    return next new Error 'signin mismatch' unless req.id is si.id
    return next! unless q = req.body.quota_daily
    err, user <- Users.findById req.id .lean!exec
    return next err if err
    return next! if user.quota_daily is q
    next new Error 'only admin can amend quota_daily'
