_ = require \lodash

module.exports = me =
  set-fns: (model, opts) ->
    model.crud-fns =
      create : me.get-invoker model, me.create
      read   : me.get-invoker model, me.read
      update : me.get-invoker model, me.update
      delete : me.get-invoker model, me.delete
      list   : me.get-invoker model, me.list
    model.on \index (err) -> log err if err
    model

  ## crud
  create: (req, res, next, model, opts) ->
    doc = new model req.body
    doc._req = req # pass req to pre-save middleware
    err, doc <- doc.save
    respond req, res, next, err, doc, opts

  read: (req, res, next, model, opts) ->
    err, doc <- model.findById req.id .lean!exec
    respond req, res, next, err, doc, opts

  update: (req, res, next, model, opts) ->
    # to apply validation and middleware we must retrieve and save
    # http://mongoosejs.com/docs/api.html#model_model.findByIdAndUpdate
    err, doc <- model.findById req.id
    return next err if err
    doc <<< req.body
    doc._req = req # pass req to pre-save middleware
    err, doc <- doc.save!
    respond req, res, next, err, doc, opts

  delete: (req, res, next, model, opts) ->
    err, doc <- model.findByIdAndRemove req.id
    respond req, res, next, err, doc, opts

  list: (req, res, next, model, opts) ->
    err, docs <- model.find!lean!exec
    respond req, res, next, err, docs, opts

  ## public helpers

  get-invoker: (model, op, opts) ->
    (req, res, next) ->
      try
        op req, res, next, model, opts
      catch
        next e

## private helpers

function respond req, res, next, err, obj, opts = {}
  return next err if err
  success = opts.success or on-success
  success req, obj, reply
  function reply err
    return next err if err
    if fields = opts.return-fields
      fields.push \_id
      if _.isArray obj
        o = _.map obj, (item) -> _.pick item, fields
      else
        o = _.pick obj, fields
    else
      o = obj
    res.json remove-null-objs o
  function on-success req, obj, done then done!

function remove-null-objs obj
  if _.isArray obj
    for o in obj then remove-null-objs o
  else
    for k, v of obj then if v is null then delete obj[k]
  obj
