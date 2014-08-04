_          = require \lodash
M          = require \mongoose
Cons       = require \../../lib/model-constraints
CryptPwd   = require \../crypt-pwd
P-Id       = require \./plugin-id
M-Users    = require \./users
#Signup     = require \../signup

spec =
  login   : type:String, required:yes, index:{+unique}, match:Cons.login.regex
  password: type:String, required:yes    # validated below

schema = new M.Schema spec
  ..plugin P-Id
  #..plugin Signup.plugin
  # password
  ..pre \save, (next) ->
    return next! unless @isModified \password
    CryptPwd.hash this, next
  ..pre \validate, (next) ->
    return next! unless @isModified \password
    is-valid = Cons.password.regex.test @password
    @invalidate \password, 'Invalid password' unless is-valid
    next!

module.exports = me = M.model \logins, schema
  ..crud-fns =
    create: (req, res, next) ->
      o = _.pick req.body, <[ login password ]>
      err, req.login <- (new me o).save # set req.login for later use by M-Users
      next err
    update: (req, res, next) ->
      if (b = req.body).password?length
        err, user <- M-Users.findById req.id
        return next err if err
        # TODO: assert auth-type is classic
        err, doc <- me.findById user.login_id
        #log \logins-update, user, b.password, err, doc
        return next err if err
        doc.password = b.password
        doc.save next
      else
        delete b.password # TODO: stop backbone sending password:''
        next!

    #delete: Crud.get-invoker me, Crud.delete, return-fields:<[ login ]>
  #..verify = (req, res, next) ->
  #    err, user <- me.findById req.id
  #    return next err if err
  #    Signup.verify req, res, next, user
