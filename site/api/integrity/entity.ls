_           = require \lodash
Err         = require \../error
M-Evidences = require \../model/evidences

module.exports =
  create: (Model) ->
    (req, res, next) ->
      err, docs <- Model.find {'meta.create_user_id':req.session.signin.id}, \_id
      return next err if err
      err, evs <- M-Evidences.find entity_id: $in:ids = _.map docs, -> it._id
      return next err if err
      entity-ids = _.uniq _.map evs, -> it.entity_id.toString!
      if (n-no-evidence = ids.length - entity-ids.length) > 0
        return next new Err.Api "Cannot create while #{n-no-evidence} of your other #{Model.modelName} are missing evidence"
      next!
