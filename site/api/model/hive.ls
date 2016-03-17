M    = require \mongoose
_    = require \lodash
P-Id = require \./plugin/id

s-hive =
  key  : type:String, required:yes, index:{+unique}
  value: type:String, required:yes

schema = new M.Schema s-hive, { collection:\hive }
  ..plugin P-Id

module.exports = me = M.model \hive schema
  ..load = (cb) ->
    err, docs <- me.find
    cb err, docs
  ..upsert = (key, value, cb) ->
    # Mongodb bug - uses ObjectId instead of ShortId
    # https://jira.mongodb.org/browse/SERVER-4175
    # The following is a workaround
    err, doc <- me.findOne key:key
    return cb err if err
    if doc # update
      doc.value = value
      err, doc <- doc.save!
      cb err, doc if cb
    else # insert
      err, doc <- (new me key:key, value:value).save
      cb err, doc if cb
