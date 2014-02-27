Model   = require \mongoose .Model
Query   = require \mongoose .Query
_       = require \underscore
H       = require \../helper

exports.create = (store) -> new Cache store

class Cache
  (@@store) ->
    H.log 'init query-by-entity cache'
    decorate-model-remove!
    decorate-model-save!
    decorate-query-find!
    decorate-query-findOneAndRemove!

  function decorate-model-remove then
    _remove = Model::remove
    Model::remove = (callback) ->
      #H.log 'Model::remove'
      _remove.call this, (err) ~>
        return callback err if err
        @@store.clear @collection.name, @entity_id if @entity_id
        callback ...

  function decorate-model-save then
    _save = Model::save
    Model::save = (callback) ->
      #H.log 'Model::save'
      _save.call this, (err, doc) ~>
        return callback err if err
        @@store.clear @collection.name, doc.entity_id if doc.entity_id
        callback ...

  function decorate-query-find then
    _execFind = Query::execFind
    Query::execFind = (callback) ->
      #H.log 'Query::execFind'
      return miss! unless (cond-keys = _.keys conds = @_conditions).length is 1
      return miss! unless cond-keys.0 is \entity_id
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean
      return hit docs if docs = @@store.get @model.modelName, (entity-id = _.values conds .0)

      _execFind.call this, (err, docs) ~>
        return callback err if err
        @@store.set @model.modelName, entity-id, docs
        callback err, docs

      function hit docs then
        H.log 'HIT!'
        return callback null, docs

      ~function miss then
        #H.log 'MISS!'
        _execFind.call this, callback

  function decorate-query-findOneAndRemove then
    _findOneAndRemove = Query::findOneAndRemove
    Query::findOneAndRemove = (callback) ->
      #H.log 'Query::findOneAndRemove'
      @@store.clear @model.modelName # not sure how to get entity_id
      _findOneAndRemove ...
