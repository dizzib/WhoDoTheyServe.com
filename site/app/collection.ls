B   = require \backbone
_   = require \underscore
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

# this must run after model extensions have been applied
# init() needed because model-ext requires this module so we can't simply require \./model-ext
module.exports.init = ->
  edges =
    url       : Api.edges
    model     : M.Edge
    comparator: (edge) ->
      function get-node-name
        id = edge.get "#{it}_node_id"
        node = me.Nodes.get id
        node.get \name
      "#{get-node-name \a}#{edge.get \how}#{get-node-name \b}"
  evidences =
    url  : Api.evidences
    model: M.Evidence
  maps =
    url       : Api.maps
    model     : M.Map
    comparator: name-comparator
  nodes =
    url       : Api.nodes
    model     : M.Node
    comparator: name-comparator
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
