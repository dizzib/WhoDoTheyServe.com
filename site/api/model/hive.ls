M = require \mongoose
_ = require \underscore
H = require \../helper

s-hive =
  key  : type:String, required:yes, index:{+unique}
  value: type:String, required:yes

schema = new M.Schema s-hive, { collection:\hive }

Model = M.model \hive, schema
  ..load = (cb) ->
    err, docs <- Model.find
    cb err, docs

  ..upsert = (key, value, cb) ->
    data = key:key, value:value
    err, doc <- Model.findOneAndUpdate key:key, data, {+upsert}
    cb err, doc if cb

module.exports = Model
