B   = require \backbone
_   = require \underscore
Api = require \./api

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

# models are dependency injected to avoid circular references
module.exports.init = (models) ->
  edges =
    url       : Api.edges
    model     : models.Edge
    comparator: (edge) ->
      function get-node-name
        return '' unless id = edge.get "#{it}_node_id"
        return id unless node = me.Nodes.get id
        node.get \name
      "#{get-node-name \a}#{edge.get \how}#{get-node-name \b}"
  evidences =
    url  : Api.evidences
    model: models.Evidence
  maps =
    url       : Api.maps
    model     : models.Map
    comparator: name-comparator
  nodes =
    url       : Api.nodes
    model     : models.Node
    comparator: name-comparator
  notes =
    url  : Api.notes
    model: models.Note
  sessions =
    url  : Api.sessions
    model: models.Session
  users =
    url       : Api.users
    model     : models.User
    find-by-id: (id) -> exports.Users.findWhere _id:id .models.0

  me = module.exports
    ..Edges     = new (Collection.extend edges)!
    ..Evidences = new (Collection.extend evidences)!
    ..Maps      = new (Collection.extend maps)!
    ..Nodes     = new (Collection.extend nodes)!
    ..Notes     = new (Collection.extend notes)!
    ..Sessions  = new (Collection.extend sessions)!
    ..Users     = new (Collection.extend users)!

# helpers

function name-comparator then it.get \name .toLowerCase!
