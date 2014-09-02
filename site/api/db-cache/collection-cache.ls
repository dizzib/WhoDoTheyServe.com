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
    decorate-query-findOneAndUpdate!
    decorate-query-remove!
    decorate-query-update!

  function decorate-model-remove
    _orig = Model::remove
    Model::remove = (cb) ->
      #log 'Model::remove'
      err <~ _orig.call this
      refresh-object @collection.name, _id:@_id unless err
      cb ...

  function decorate-model-save
    _orig = Model::save
    Model::save = (cb) ->
      #log 'Model::save'
      err, doc <~ _orig.call this
      refresh-object @collection.name, { _id:doc._id }, doc unless err
      cb ...

  function decorate-query-find
    _orig = Query::_execFind = Query::execFind # orig used by sweeper
    Query::execFind = (cb) ->
      #log 'Query::execFind'
      return miss! unless _.isEmpty conds = @_conditions
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean
      return hit docs if docs = @@store.get @model.modelName, STORE-KEY

      _orig.call this, (err, docs) ~>
        unless err
          @@store.set @model.modelName, STORE-KEY, docs
          @@store.set-query @model.modelName, STORE-KEY, this
        cb ...

      function hit docs then
        #log 'HIT!'
        cb null, docs

      ~function miss then
        #log 'MISS!'
        _orig.call this, cb

  function decorate-query-findOne
    _orig = Query::findOne
    Query::findOne = (cb) ->
      #log 'Query.findOne', @_conditions
      return miss! unless _.isEmpty @_fields
      return miss! unless (opts = @_optionsForExec @model).lean
      return miss! unless docs = @@store.get @model.modelName, STORE-KEY

      cb null, _.find docs, @_conditions

      ~function miss
        #log 'MISS!'
        _orig.call this, cb

  function decorate-query-findOneAndRemove
    _orig = Query::findOneAndRemove
    Query::findOneAndRemove = (cb) ->
      #log 'Query::findOneAndRemove'
      err <~ _orig.call this
      refresh-object @model.modelName, @_conditions unless err
      cb ...

  function decorate-query-findOneAndUpdate
    _orig = Query::findOneAndUpdate
    Query::findOneAndUpdate = (cb) ->
      #log 'Query::findOneAndUpdate', @_conditions, @_updateArg
      err, doc <~ _orig.call this
      refresh-object @model.modelName, @_conditions, doc unless err
      cb ...

  function decorate-query-remove
    Query::remove = -> throw new Error 'not implemented'

  function decorate-query-update
    Query::update = -> throw new Error 'not implemented'

  function refresh-object coll-name, conds, o
    #log 'refresh-object', coll-name, conds, o
    return unless docs = @@store.get coll-name, STORE-KEY
    docs = _.reject docs, conds
    docs.push(o._doc or o) if o
    @@store.set coll-name, STORE-KEY, docs
