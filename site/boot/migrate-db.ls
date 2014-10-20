# db migration scripts
#
# Some releases may require one-off database changes.
#
# Place scripts here as required.
#
module.exports =
  Issue6: (cb) ->
    M-Edges = require \../api/model/edges
    log 'drop index edges.a_node_id_1_b_node_id_1...'
    err <- M-Edges.collection.dropIndex \a_node_id_1_b_node_id_1
    if err
      log '...failed', err
      return cb err
    log '...ok'
    cb!
