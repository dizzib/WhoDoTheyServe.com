M      = require \mongoose
_      = require \underscore
H      = require \./helper
M-Hive = require \./model/hive

cache = {}

exports
  ..init = (cb) ->
    err, docs <- M-Hive.load
    throw err if err
    _.each docs, -> cache[it.key] = it.value
    cb! if cb

  ..get = (key) ->
    cache[key]

  ..set = (key, value, cb) ->
    cache[key] = value
    M-Hive.upsert ...

  ..read = (req, res, next) ->
    res.json value:exports.get req.key

  ..write = (req, res, next) ->
    exports.set req.key, req.body.value, (err, doc) ->
      return next err if err
      res.json doc
