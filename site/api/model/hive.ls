M    = require \mongoose
_    = require \lodash
H    = require \../helper
P-Id = require \./plugin-id

s-hive =
  key  : type:String, required:yes, index:{+unique}
  value: type:String, required:yes

schema = new M.Schema s-hive, { collection:\hive }
  ..plugin P-Id

module.exports = me = M.model \hive, schema
  ..load = (cb) ->
    err, docs <- me.find
    cb err, docs
  ..upsert = (key, value, cb) ->
    data = key:key, value:value
    err, doc <- me.findOneAndUpdate key:key, data, {+upsert}
    cb err, doc if cb
