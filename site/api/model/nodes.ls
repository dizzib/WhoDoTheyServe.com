M         = require \mongoose
Cons      = require \../../lib/model-constraints
Crud      = require \../crud
H         = require \../helper
P-Id      = require \./plugin-id
P-Meta    = require \./plugin-meta

schema = new M.Schema do
  name : type:String, required:yes, match:Cons.node.name.regex

schema
  ..plugin P-Id
  ..plugin P-Meta
  # TODO: refactor when mongo allows case-insensitive unique index
  # https://jira.mongodb.org/browse/SERVER-90
  ..pre \save, (next) ->
    err, node <~ me.findOne name:get-regexp @name
    return next err if err
    return next! unless node
    return next new H.ApiError "Duplicate detected: #{node.name}"
    next!

module.exports = me = Crud.set-fns (M.model \nodes, schema)

function get-regexp name then
  name = name.replace /\!/g, '\\!'
  name = name.replace /\(/g, '\\('
  name = name.replace /\)/g, '\\)'
  new RegExp "^#{name}$", \i
