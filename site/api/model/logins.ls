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
      adjust-fields b
      err, req.login <- (new me o).save # set req.login for later use by M-Users
      next err
    read: (req, res, next) ->
      err, req.login <- get-login req # set req.login for later use by M-Users
      next err
    update: (req, res, next) ->
      err, login <- get-login req
      return next err unless login? # bail if openauth
      delete b.password unless (b = req.body).password?length # TODO: stop backbone sending password:''
      _.extend login, _.pick b, <[ handle password ]>
      adjust-fields b
      login.save next
    delete: (req, res, next) ->
      err, user <- M-Users.findById req.id
      return next err if err
      err <- me.findByIdAndRemove user.login_id
      next err

## helpers

function adjust-fields # for later use by M-Users
  it.name?  = it.handle # force name to be handle (if supplied)
  it.handle = it.password = void # clear fields

function get-login req, cb
  err, user <- M-Users.findById req.id
  return cb err if err
  return cb! unless user
  return cb! unless M-Users.check-is-authtype-password user
  me.findById user.login_id, cb
