M      = require \mongoose
_      = require \underscore
H      = require \./helper
M-Hive = require \./model-hive

cache = {}

exports
  ..init = ->
    M-Hive.load (docs) -> _.each docs, -> cache[it.key] = it.value

  ..get = (req, res, next) ->
    key = req.key
    return next new H.ApiError "#{key} not found" unless _.has cache, key
    res.send cache[key]

  ..set = (req, res, next) ->
    cache[req.key] = req.body.value
    M-Hive.upsert ...
