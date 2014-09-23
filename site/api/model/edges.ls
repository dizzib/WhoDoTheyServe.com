M      = require \mongoose
_      = require \lodash
Cons   = require \../../lib/model-constraints
When   = require \../../lib/when
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
  ..plugin P-Id
  ..plugin P-Meta
  ..pre \validate, (next) ->
    if @a_node_id is @b_node_id then @invalidate \a_node_id, 'Nodes A and B must differ'
    next!

module.exports = me = Crud.set-fns (M.model \edges, schema)
