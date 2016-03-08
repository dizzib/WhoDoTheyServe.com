B   = require \backbone
_   = require \underscore
Api = require \./api
Fpx = require \./fireprox

c = B.Collection.extend do
  destroy: (id-or-model, opts) ->   # complement of @create convenience
    model = if _.isString id-or-model then @get(id-or-model) else id-or-model
    success = opts.success
    opts.success = (model, resp, opts) ~>
      @remove model, opts
      success model, resp, opts if success
    model.destroy opts
  find: ->
    new c @filter it
  toJSON-T: (opts) ->
    @map (m) -> if m.toJSON-T then m.toJSON-T opts else m.toJSON opts

# For performance and flexibility, models can require collections which means we can't
# require models here or we'd get circular refs. Therefore models are dependency injected.
module.exports.init = (models) ->
  edges = c.extend do
    url       : Api.edges
    model     : models.Edge
    comparator: (edge) ->
      function get-node-name
        return '' unless id = edge.get "#{it}_node_id"
        return id unless node = me.Nodes.get id
        node.get \name
      "#{get-node-name \a}#{edge.get \how}#{get-node-name \b}"

  evidences = c.extend do
    url        : Api.evidences
    model      : models.Evidence
    auto-create: (entity-id, cb) ->
      url <- Fpx.get-browser-url
      return cb! unless url
      ev = models.Evidence.create entity_id:entity-id, url:url
      me.Evidences.create ev, { +merge, +wait, success:-> cb ok:true }

  maps = c.extend do
    url       : Api.maps
    model     : models.Map
    comparator: name-comparator

  nodes = c.extend do
    url       : Api.nodes
    model     : models.Node
    comparator: name-comparator
    tags      : -> _.uniq _.flatten _.filter (@pluck \tags), -> it
    with-tag  : (tag) -> new c @filter -> _.contains (it.get \tags), tag

  notes = c.extend do
    url  : Api.notes
    model: models.Note

  sessions = c.extend do
    url  : Api.sessions
    model: models.Session

  users = c.extend do
    url       : Api.users
    model     : models.User

  me = module.exports
    ..edges     = edges
    ..evidences = evidences
    ..nodes     = nodes
    ..notes     = notes

    ..Edges     = new edges!
    ..Evidences = new evidences!
    ..Maps      = new maps!
    ..Nodes     = new nodes!
    ..Notes     = new notes!
    ..Sessions  = new sessions!
    ..Users     = new users!

## helpers

function name-comparator then it.get \name .toLowerCase!
