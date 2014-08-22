module.exports = (schema) ->

  schema
    ..add do
      meta:
        create_date   : type:Date  , default:Date.now
        create_user_id: type:String, required:yes
        update_date   : type:Date
        update_user_id: type:String
    ..pre \save, (next) ->
      return next! if @isNew
      @set \meta.update_date, new Date!
      @set \meta.update_user_id, @_req.session.signin.id # @_req is populated by crud.update
      next!
