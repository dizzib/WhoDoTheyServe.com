Model  = require \mongoose .Model
MQuery = require \mongoose/node_modules/mquery
_      = require \lodash

exports.create = (store) -> new Cache store

class Cache
  (@@store) ->
    log 'init query-by-entity cache'
    decorate-model-remove!
    decorate-model-save!
    decorate-mquery-find!
    decorate-mquery-findOneAndRemove!

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

  function decorate-mquery-find
    _orig = MQuery::find
    MQuery::find = (crit, cb) ->
      #log 'MQuery::find'
      return _orig ... unless _.isFunction cb
      return miss! unless (cond-keys = _.keys conds = @_conditions).length is 1
      return miss! unless cond-keys.0 is \entity_id
      return miss! unless _.isEmpty @_fields
      return miss! unless @_mongooseOptions.lean
      return hit docs if docs = @@store.get @model.modelName, (entity-id = _.values conds .0)
      return _orig.apply this, [crit, cb-set]

      function hit docs
        #log 'HIT!'
        return cb null, docs

      ~function miss
        #log 'MISS!'
        _orig.apply this, [crit, cb]

      ~function cb-set err, docs
        @@store.set @model.modelName, entity-id, docs unless err
        cb err, docs

  function decorate-mquery-findOneAndRemove
    _orig = MQuery::findOneAndRemove
    MQuery::findOneAndRemove = ->
      #log 'MQuery::findOneAndRemove'
      @@store.clear @model.modelName # not sure how to get entity_id
      _orig ...
