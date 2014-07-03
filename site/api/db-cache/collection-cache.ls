Model = require \mongoose .Model
Query = require \mongoose .Query
_     = require \lodash

const STORE-KEY = \COLLECTION

exports.create = (store) -> new Cache store

class Cache
  (@@store) ->
    log 'init collection cache'
    decorate-model-remove!
    decorate-model-save!
    decorate-query-find!
    decorate-query-findOne!
    decorate-query-findOneAndRemove!
    decorate-query-remove!
    decorate-query-update!

  function decorate-model-remove then
    _remove = Model::remove
    Model::remove = (callback) ->
      #log 'Model::remove'
      _remove.call this, (err) ~>
        return callback err if err
        update-by-id @collection.name, @_id
        callback ...

  function decorate-model-save then
    _save = Model::save
    Model::save = (callback) ->
      #log 'Model::save'
      _save.call this, (err, doc) ~>
        return callback err if err
        update-by-id @collection.name, doc._id, doc
        callback ...

  function decorate-query-find then
    Query::_execFind = _execFind = Query::execFind
    Query::execFind = (callback) ->
      #log 'Query::execFind'
      return miss! unless _.isEmpty conds = @_conditions
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean
      return hit docs if docs = @@store.get @model.modelName, STORE-KEY

      _execFind.call this, (err, docs) ~>
        return callback err if err
        @@store.set @model.modelName, STORE-KEY, docs
        @@store.set-query @model.modelName, STORE-KEY, this
        callback err, docs

      function hit docs then
        #log 'HIT!'
        callback null, docs

      ~function miss then
        #log 'MISS!'
        _execFind.call this, callback

  function decorate-query-findOne then
    _findOne = Query::findOne
    Query::findOne = (callback) ->
      #log 'Query.findOne'
      return miss! unless (cond-keys = _.keys conds = @_conditions).length is 1
      return miss! unless cond-keys.0 is \_id
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean

      return miss! unless docs = @@store.get @model.modelName, STORE-KEY
      doc = _.find docs, (d) -> d._id is conds._id
      callback null, doc

      ~function miss then
        #log 'MISS!'
        _findOne.call this, callback

  function decorate-query-findOneAndRemove then
    _findOneAndRemove = Query::findOneAndRemove
    Query::findOneAndRemove = (callback) ->
      #log 'Query::findOneAndRemove'
      update-by-id @model.modelName, @_conditions._id
      _findOneAndRemove ...

  function decorate-query-remove then
    Query::remove = -> throw new Error 'not implemented'

  function decorate-query-update then
    Query::update = -> throw new Error 'not implemented'

  # in-situ update is probably faster than refreshing from db
  function update-by-id coll-name, id, doc then
    #log 'REFRESH'
    docs = @@store.get coll-name, STORE-KEY
    docs = docs or {}
    docs = _.reject docs, (d) -> d._id is id
    docs.push doc if doc
    @@store.set coll-name, STORE-KEY, docs
