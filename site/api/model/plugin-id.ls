ShortId   = require \shortid

module.exports = (schema) ->
  schema.add do
    _id: type:String, unique:yes, default:ShortId.generate
