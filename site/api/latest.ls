_           = require \lodash
M-Edges     = require \./model/edges
M-Maps      = require \./model/maps
M-Nodes     = require \./model/nodes
M-Notes     = require \./model/notes
M-Evidences = require \./model/evidences

var cache

module.exports =
  bust-cache: (req, res, next) ->
    cache := void unless req.method is \GET
    next!

  # return all entities and dependencies required to render latest
  list: (req, res, next) ->
    return res.json cache if cache?

    function get-ents model, type, cb
      err, docs <- model.find!lean!exec
      cb err, [o <<< _type:type for o in docs]

    err, maps <- M-Maps.find!lean!exec
    return next err if err
    maps = [_.pick(m, <[ _id name meta ]>) <<< _type:\map for m in
      _.reject maps, -> it.flags?private]
    err, edges <- get-ents M-Edges, \edge
    return next err if err
    err, nodes <- get-ents M-Nodes, \node
    return next err if err
    err, notes <- get-ents M-Notes, \note
    return next err if err

    all     = edges ++ maps ++ nodes ++ notes
    by-date = _.sortBy all, (o) -> o.meta.update_date or o.meta.create_date
    latest  = _.reverse _.takeRight by-date, 50
    ents    =
      edges: _.filter latest, _type:\edge
      maps : _.filter latest, _type:\map
    # add dependencies
    edge-node-ids = _.uniq (_.map ents.edges, \a_node_id) ++ (_.map ents.edges, \b_node_id)
    edge-nodes = _.intersectionWith nodes, edge-node-ids, (a, b) -> a._id is b
    ents.nodes = (_.filter latest, _type:\node) ++ edge-nodes
    nodes-and-edges = ents.nodes ++ ents.edges
    err, ents.evidences <- M-Evidences.find-for-entities nodes-and-edges
    return next err if err
    err, ents.notes <- M-Notes.find-for-entities nodes-and-edges
    return next err if err

    cache :=
      ids: [_.pick o, <[ _id _type ]> for o in latest]
      entities: ents
    res.json cache
