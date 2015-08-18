E = require \../error
M = require \../model/maps

module.exports =
  read: (req, res, next) ->
    return next! if (si = req.session.signin)?role is \admin
    err, map <- M.findById req.id .lean!exec
    return next err if err
    if map.flags?private and (not si or (si.id isnt map.meta.create_user_id))
      return next new E.Api 'Permission denied'
    next!
