M = require \mongoose

module.exports = (schema) ->

  S-Vote = new M.Schema do
    user_id : type:M.Schema.ObjectId, required:yes, index:yes
    delta   : type:Number           , required:yes

  schema.add do
    meta:
      create_date   : type:Date             , index:yes, default:Date.now
      create_user_id: type:M.Schema.ObjectId, index:yes, required:yes
      votes         : type:[S-Vote]
