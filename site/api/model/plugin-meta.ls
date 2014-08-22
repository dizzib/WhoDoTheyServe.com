module.exports = (schema) ->
  schema
    ..add do
      meta:
        create_date   : type:Date, default:Date.now
        create_user_id: type:String
        update_date   : type:Date
        update_user_id: type:String
    ..pre \validate, (next) ->
      # @_req should be populated by crud on a normal create or update request, as this is
      # a the easiest way to access the req from mongoose middleware.
      if @isNew
        return next! if @get \meta.create_user_id # already populated if e.g. new user
        @invalidate \meta.create_user_id, \session-required unless sid = @_req?session.signin.id
        @set \meta.create_user_id, sid
      else
        # bail if we're not yet logged in e.g. unfreeze user
        return next! unless sid = @_req?session.signin.id
        @set \meta.update_date, new Date!
        @set \meta.update_user_id, sid
      next!
