M      = require \mongoose
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
P-Id   = require \./plugin-id
P-Meta = require \./plugin-meta

schema = new M.Schema do
  name : type:String, required:yes, match:Cons.map.name.regex
  #nodes: type:String, required:yes # json list of node ids and xy coords

schema
  ..plugin P-Id
  ..plugin P-Meta

module.exports = me = Crud.set-fns (M.model \maps, schema)
