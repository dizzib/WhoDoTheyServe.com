M      = require \mongoose
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
P-Id   = require \./plugin-id
P-Meta = require \./plugin-meta

schema-node = new M.Schema do
  _id: type:String, required:yes
  #x : type:Number, required:yes
  #y : type:Number, required:yes

schema = new M.Schema do
  name : type:String, required:yes, match:Cons.map.name.regex
  nodes: [schema-node]

schema
  ..plugin P-Id
  ..plugin P-Meta

module.exports = me = Crud.set-fns (M.model \maps, schema)
  ..crud-fns
    ..list = Crud.get-invoker me, Crud.list, return-fields:<[ name ]>

