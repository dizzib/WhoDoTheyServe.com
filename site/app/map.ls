C  = require \./collection
H  = require \./helper
Hi = require \./hive
M  = require \./model

module.exports = me =
  fetch: (id, cb) ->
    return cb null, M.Map.create! unless id?
    return cb new Error "Unable to get map #id" unless m = C.Maps.get id
    return cb null, m if m.has-been-fetched! # for speed, assume map unlikely to have changed in the db
    m.fetch error:H.on-err, success: ->
      es = m.get \entities
      models =
        edges    : _.map es.edges, -> new M.Edge it
        evidences: _.map es.evidences, -> new M.Evidence it
        nodes    : _.map es.nodes, -> new M.Node it
        notes    : _.map es.notes, -> new M.Note it
      m.set \entities, models
      C.Maps.add m, merge:true

      # add to global collections
      C.Nodes.set models.nodes, remove:false # add nodes first so edge comparator can read node names
      C.Edges.set models.edges, remove:false
      C.Evidences.set models.evidences, remove:false
      C.Notes.set models.notes, remove:false

      cb null, m

  fetch-default: (cb) ->
    id = me.get-default-id!
    return cb new Error "Unable to fetch default map" unless id?
    me.fetch id, cb

  get-default-id: ->
    (JSON.parse Hi.Map.get \value).default?id
