M      = require \mongoose
_      = require \lodash
Eh     = require \../../lib/edge-helper
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
H      = require \../helper
P-Id   = require \./plugin-id
P-Meta = require \./plugin-meta

spec =
  a_node_id : type:String, required:yes
  b_node_id : type:String, required:yes, index:yes
  a_is      : type:String, required:yes, enum:<[eq lt]>
  how       : type:String, required:no , match:Cons.edge.how.regex
  when      : type:String, required:no , match:Cons.edge.when.regex

schema = new M.Schema spec
  ..index { a_node_id:1, b_node_id:1 }, {+unique}
  ..plugin P-Id
  ..plugin P-Meta
  ..pre \validate, (next) ->
    try Eh.parse-when @when catch e then @invalidate \when, e.message
    if @a_node_id is @b_node_id then @invalidate \a_node_id, 'Nodes A and B must differ'
    next!
  ..pre \save, (next) ->
    err, edge <~ me.findById @_id
    return next err if err
    # If update then allow inversion a--b to b--a
    return next! if edge?a_node_id is @b_node_id and edge?b_node_id is @a_node_id
    err, obj <~ me.findOne $and:
      * a_node_id:@b_node_id
      * b_node_id:@a_node_id
    return next err if err
    return next new H.ApiError 'Reciprocal duplicate detected' if obj
    next!

module.exports = me = Crud.set-fns (M.model \edges, schema)
