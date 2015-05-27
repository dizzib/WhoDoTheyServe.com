Model  = require \mongoose .Model
MQuery = require \mongoose/node_modules/mquery
_      = require \lodash

const STORE-KEY = \COLLECTION

exports.create = (store) -> new Cache store

class Cache
  (@@store) ->
    log 'init collection cache'
    decorate-model-remove!
    decorate-model-save!
    decorate-mquery-find!
    decorate-mquery-findOne!
    decorate-mquery-findOneAndRemove!
    decorate-mquery-findOneAndUpdate!
    decorate-mquery-remove!
    decorate-mquery-update!

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

  function decorate-mquery-find
    _orig = MQuery::_find = MQuery::find # orig used by sweeper
    MQuery::find = (crit, cb) ->
      #log 'MQuery::find'
      return _orig ... unless _.isFunction cb
      return miss! unless _.isEmpty conds = @_conditions
      return miss! unless _.isEmpty @_fields
      return miss! unless @_mongooseOptions.lean
      return hit docs if docs = @@store.get @model.modelName, STORE-KEY
      return _orig.apply this, [crit, cb-set]

      function hit docs
        #log 'HIT!'
        cb null, docs

      ~function miss
        #log 'MISS!'
        _orig.apply this, [crit, cb]

      ~function cb-set err, docs
        unless err
          @@store.set @model.modelName, STORE-KEY, docs
          @@store.set-query @model.modelName, STORE-KEY, this
        cb ...

  function decorate-mquery-findOne
    _orig = MQuery::findOne
    MQuery::findOne = (crit, cb) ->
      #log 'MQuery.findOne', @_conditions
      return _orig ... unless _.isFunction cb
      return miss! unless _.isEmpty @_fields
      return miss! unless @_mongooseOptions.lean
      return miss! unless docs = @@store.get @model.modelName, STORE-KEY
      return cb null, _.find docs, @_conditions

      ~function miss
        #log 'MISS!'
        _orig.apply this, [crit, cb]

  function decorate-mquery-findOneAndRemove
    _orig = MQuery::findOneAndRemove
    MQuery::findOneAndRemove = (crit, opts, cb) ->
      #log 'MQuery::findOneAndRemove', arguments
      return _orig ... unless _.isFunction cb
      return _orig.apply this, [crit, opts, refresh]

      ~function refresh err
        refresh-object @model.modelName, crit unless err
        cb ...

  function decorate-mquery-findOneAndUpdate
    _orig = MQuery::findOneAndUpdate
    MQuery::findOneAndUpdate = (crit, doc, opts, cb) ->
      #log 'MQuery::findOneAndUpdate', arguments
      return _orig ... unless _.isFunction cb
      return _orig.apply this, [crit, doc, (opts or {}) <<< new:true, refresh]

      ~function refresh err, doc
        refresh-object @model.modelName, crit, doc unless err
        cb ...

  function decorate-mquery-remove
    MQuery::remove = -> throw new Error 'not implemented'

  function decorate-mquery-update
    MQuery::update = -> throw new Error 'not implemented'

  function refresh-object coll-name, conds, o
    #log 'refresh-object', coll-name, conds, o
    return unless docs = @@store.get coll-name, STORE-KEY
    docs = _.reject docs, conds
    docs.push(o._doc or o) if o
    @@store.set coll-name, STORE-KEY, docs
