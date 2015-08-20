M      = require \mongoose
_      = require \lodash
H      = require \./helper
M-Hive = require \./model/hive

cache = {}

module.exports = me =
  init: (cb) ->
    err, docs <- M-Hive.load
    return cb err if err
    _.each docs, -> cache[it.key] = it.value
    cb!

  get: (key) ->
    cache[key]

  set: (key, value, cb) ->
    cache[key] = value
    M-Hive.upsert ...

  read: (req, res, next) ->
    res.json value:me.get req.key

  write: (req, res, next) ->
    me.set req.key, req.body.value, (err, doc) ->
      return next err if err
      res.json doc
