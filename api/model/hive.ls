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
    throw err if err
    cb docs

  ..upsert = (req, res, next) ->
    [k, v] = [req.key, req.body.value]
    err, doc <- Model.findOneAndUpdate key:k, { key:k, value:v }, {+upsert}
    return next err if err
    res.json doc

module.exports = Model
