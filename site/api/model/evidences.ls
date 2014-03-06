M      = require \mongoose
_      = require \underscore
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
P-Meta = require \./plugin-meta

s-evidences =
  entity_id : type:M.Schema.ObjectId, required:yes
  url       : type:String           , required:yes, match:Cons.url.regex

schema = new M.Schema s-evidences
  ..index { entity_id:1, url:1 }, {+unique}
  ..plugin P-Meta

module.exports = me = Crud.set-fns (M.model \evidences, schema)
  ..crud-fns.list-for-entity = (req, res, next) ->
    err, docs <- me.find entity_id:req.id .lean!exec
    return next err if err
    res.json docs
