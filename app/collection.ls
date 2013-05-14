_   = require \underscore
B   = require \backbone
Api = require \./api
M   = require \./model

Collection = B.Collection.extend do
  destroy: (id-or-model, opts) ->   # complement of @create convenience
    model = if _.isString id-or-model then @get(id-or-model) else id-or-model
    success = opts.success
    opts.success = (model, resp, opts) ~>
      @remove model, opts
      success model, resp, opts if success
    model.destroy opts
  find: ->
    new Collection @filter it
  toJSON-T: (opts) ->
    @map (m) -> if m.toJSON-T then m.toJSON-T opts else m.toJSON opts

exports.init = ->
  edges =
    url  : Api.edges
    model: M.Edge
  evidences =
    url  : Api.evidences
    model: M.Evidence
  nodes =
    url       : Api.nodes
    model     : M.Node
    comparator: -> it.get \name .toLowerCase!
  notes =
    url  : Api.notes
    model: M.Note
  sessions =
    url  : Api.sessions
    model: M.Session
  users =
    url       : Api.users
    model     : M.User
    find-by-id: (id) -> exports.Users.findWhere _id:id .models.0

  exports
    ..Edges     = new (Collection.extend edges)!
    ..Evidences = new (Collection.extend evidences)!
    ..Nodes     = new (Collection.extend nodes)!
    ..Notes     = new (Collection.extend notes)!
    ..Sessions  = new (Collection.extend sessions)!
    ..Users     = new (Collection.extend users)!
