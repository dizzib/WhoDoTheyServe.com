# db migration scripts
#
# Some releases may require one-off database changes.
#
# Place scripts here as required.
#
module.exports =
  drop-evidences-index: (cb) ->
    M = require \../api/model/evidences
    log 'drop index evidences.entity_id_1_url_1'
    err <- M.collection.dropIndex \entity_id_1_url_1
    cb err
