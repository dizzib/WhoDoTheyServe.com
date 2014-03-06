M      = require \mongoose
_      = require \underscore
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
P-Meta = require \./plugin-meta

s-evidences =
  entity_id : type:M.Schema.ObjectId, required:yes
  text      : type:String           , required:yes, match:Cons.note.regex

schema = new M.Schema s-evidences
  ..plugin P-Meta
  ..index { entity_id:1, 'meta.create_user_id':1 }, {+unique}

module.exports = me = Crud.set-fns M.model \notes, schema
  ..crud-fns.list-for-entity = (req, res, next) ->
    err, docs <- me.find entity_id:req.id .lean!exec
    return next err if err
    res.json docs
