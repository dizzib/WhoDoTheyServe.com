H       = require \./helper
M-Users = require \./model/users

module.exports =
  admin: (req, res, next) ->
    return next new Error 'signin required' unless si = req.session.signin
    return next! if si.role is \admin
    return next new Error 'admin signin required'

  create: (Model) ->
    (req, res, next) ->
      return next new Error 'signin required' unless si = req.session.signin

      ## check user isn't too prolific (sign of malicious hack perhaps?)
      err, user <- M-Users.findById si.id
      next err if err
      err, n <- Model.count $and:
        * 'meta.create_user_id': si.id
        * 'meta.create_date'   : $gte:H.get-date-yesterday!
      next err if err
      if user.quota_daily? then
        const multipliers =
          nodes    : 1
          edges    : 1
          evidences: 2
        if n >= (limit = multipliers[Model.modelName] * user.quota_daily)
          return next new H.ApiError "
          Your 24-hour contribution limit of #{limit} #{Model.modelName} has been reached! 
          Contact admin to have your limit increased or wait 24 hours before retrying."
      next!

  amend: (Model) ->
    (req, res, next) ->
      err, doc <- Model.findOne _id:req.id
      return next err if err
      return next new Error "entity #{req.id} not found for update/delete" unless doc
      return next new Error 'signin required' unless si = req.session.signin
      return next! if doc.meta.create_user_id is si.id or si.role is \admin
      next new Error 'signin must be the creator or admin'
