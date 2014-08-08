Model = require \mongoose .Model
Query = require \mongoose .Query
_     = require \lodash

exports.create = (store) -> new Cache store

class Cache
  (@@store) ->
    log 'init query-by-entity cache'
    decorate-model-remove!
    decorate-model-save!
    decorate-query-find!
    decorate-query-findOneAndRemove!

  function decorate-model-remove
    _orig = Model::remove
    Model::remove = (cb) ->
      #log 'Model::remove'
      err <~ _orig.call this
      @@store.clear @collection.name, @entity_id if @entity_id unless err
      cb ...

  function decorate-model-save
    _orig = Model::save
    Model::save = (cb) ->
      #log 'Model::save'
      err, doc <~ _orig.call this
      @@store.clear @collection.name, doc.entity_id if doc.entity_id unless err
      cb ...

  function decorate-query-find
    _orig = Query::execFind
    Query::execFind = (cb) ->
      #log 'Query::execFind'
      return miss! unless (cond-keys = _.keys conds = @_conditions).length is 1
      return miss! unless cond-keys.0 is \entity_id
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean
      return hit docs if docs = @@store.get @model.modelName, (entity-id = _.values conds .0)

      function hit docs
        #log 'HIT!'
        return cb null, docs

      ~function miss
        #log 'MISS!'
        _orig.call this, cb

      err, docs <~ _orig.call this
      @@store.set @model.modelName, entity-id, docs unless err
      cb err, docs

  function decorate-query-findOneAndRemove
    _orig = Query::findOneAndRemove
    Query::findOneAndRemove = ->
      #log 'Query::findOneAndRemove'
      @@store.clear @model.modelName # not sure how to get entity_id
      _orig ...
