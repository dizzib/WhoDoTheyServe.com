_ = require \lodash

module.exports = me =
  set-fns: (Model, opts) ->
    Model.crud-fns =
      create : me.get-invoker Model, me.create
      read   : me.get-invoker Model, me.read
      update : me.get-invoker Model, me.update
      delete : me.get-invoker Model, me.delete
      list   : me.get-invoker Model, me.list
    Model

  ## crud
  create: (req, res, next, Model, opts) ->
    err, doc <- (new Model req.body).save
    respond req, res, next, err, doc, opts

  read: (req, res, next, Model, opts) ->
    err, doc <- Model.findById req.id .lean!exec
    respond req, res, next, err, doc, opts

  update: (req, res, next, Model, opts) ->
    # to apply validation and middleware we must retrieve and save
    # http://mongoosejs.com/docs/api.html#model_Model.findByIdAndUpdate
    err, doc <- Model.findById req.id
    return next err if err
    doc : _.extend doc, req.body
    err, doc <- doc.save!
    respond req, res, next, err, doc, opts

  delete: (req, res, next, Model, opts) ->
    err <- Model.findByIdAndRemove req.id
    respond req, res, next, err, req.body, opts

  list: (req, res, next, Model, opts) ->
    err, docs <- Model.find!lean!exec
    respond req, res, next, err, docs, opts

  ## public helpers

  get-invoker: (Model, op, opts) ->
    (req, res, next) ->
      try
        op req, res, next, Model, opts
      catch
        next e

## private helpers

function respond req, res, next, err, obj, opts = {} then
  return next err if err
  success = opts.success or on-success
  success req, obj, reply
  function reply err then
    return next err if err
    if fields = opts.return-fields then
      fields.push \_id
      if _.isArray obj then
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
