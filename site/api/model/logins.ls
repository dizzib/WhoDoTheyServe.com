_        = require \lodash
M        = require \mongoose
Cons     = require \../../lib/model-constraints
CryptPwd = require \../crypt-pwd
H        = require \../helper
P-Id     = require \./plugin-id
M-Users  = require \./users

spec =
  handle  : type:String, required:yes, index:{+unique}, match:Cons.handle.regex
  password: type:String, required:yes

schema = new M.Schema spec
  ..plugin P-Id
  ..pre \save, (next) ->     # hash password
    return next! unless @isModified \password
    CryptPwd.hash this, next
  ..pre \validate, (next) -> # validate password
    return next! unless @isModified \password
    is-valid = Cons.password.regex.test @password
    @invalidate \password, 'Invalid password' unless is-valid
    next!

module.exports = me = M.model \logins, schema
  ..crud-fns =
    create: (req, res, next) ->
      o = _.pick (b = req.body), <[ handle password ]>
      b.handle = b.password = void # fields not used by M-Users
      err, req.login <- (new me o).save # set req.login for later use by M-Users
      next err
    read: (req, res, next) ->
      err, user <- M-Users.findById req.id
      return next err if err
      return next! unless M-Users.check-is-authtype-password user
      err, req.login <- me.findById user.login_id # set req.login for later use by M-Users
      next err
    update: (req, res, next) ->
      unless (b = req.body).password?length
        delete b.password # TODO: stop backbone sending password:''
        return next!
      err, user <- M-Users.findById req.id
      return next err if err
      return next new H.ApiError "auth_type must be password" unless M-Users.check-is-authtype-password user
      err, doc <- me.findById user.login_id
      return next err if err
      doc.password = b.password
      doc.save next
    delete: (req, res, next) ->
      err, user <- M-Users.findById req.id
      return next err if err
      err <- me.findByIdAndRemove user.login_id
      next err
