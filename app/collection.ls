_ = require \underscore
B = require \backbone
H = require \./helper
M = require \./model

Collection = B.Collection.extend do
  find: -> new Collection @filter it
  destroy: (id-or-model, opts) ->   # complement of @create convenience
    model = if _.isString id-or-model then @get(id-or-model) else id-or-model
    success = opts.success
    opts.success = (model, resp, opts) ~>
      @remove model, opts
      success model, resp, opts if success
    model.destroy opts
  toJSON-T: (opts) ->
    @map (m) -> if m.toJSON-T then m.toJSON-T opts else m.toJSON opts

exports.init = ->
  edges =
    url  : '/api/edges'
    model: M.Edge
  evidences =
    url  : '/api/evidences'
    model: M.Evidence
  nodes =
    url       : '/api/nodes'
    model     : M.Node
    comparator: -> it.get \name .toLowerCase!
  notes =
    url  : '/api/notes'
    model: M.Note
  sessions =
    url  : '/api/sessions'
    model: M.Session
  users =
    url       : '/api/users'
    model     : M.User
    find-by-id: (id) -> exports.Users.findWhere _id:id .models.0

  exports
    ..Edges     = new (Collection.extend edges)!
    ..Evidences = new (Collection.extend evidences)!
    ..Nodes     = new (Collection.extend nodes)!
    ..Notes     = new (Collection.extend notes)!
    ..Sessions  = new (Collection.extend sessions)!
    ..Users     = new (Collection.extend users)!
