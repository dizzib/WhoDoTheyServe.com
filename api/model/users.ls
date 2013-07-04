M          = require \mongoose
H          = require \../helper
Cons       = require \../../lib/model-constraints
Crypt      = require \../crypt
CryptPwd   = require \../crypt-pwd
Crud       = require \../crud
M-Sessions = require \./sessions
Signup     = require \../signup

spec =
  login       : type:String, required:yes, index:{+unique}, match:Cons.login.regex
  password    : type:String, required:yes    # validated below
  email       : type:String, index:{+unique} # validated below
  info        : type:String, match:Cons.url.regex
  role        : type:String, required:yes, enum:<[ admin user ]>
  create_date : type:Date  , required:yes, default:Date.now
  quota_daily : type:Number, required:yes, default:5
  freeze_until: type:String  # allow sign-in only after this datetime

schema = new M.Schema spec
  ..plugin Signup.plugin
  # email
  ..pre \save, (next) ->
    return next! unless @isModified \email
    @email = Crypt.encrypt @email
    next!
  ..pre \validate, (next) ->
    return next! unless @isModified \email
    @invalidate \email, 'Invalid email' unless Cons.email.regex.test @email
    next!
  # password
  ..pre \save, (next) ->
    return next! unless @isModified \password
    CryptPwd.hash this, next
  ..pre \validate, (next) ->
    return next! unless @isModified \password
    is-valid = Cons.password.regex.test @password
    @invalidate \password, 'Invalid password' unless is-valid
    next!

module.exports = Users = M.model \users, schema
  ..crud-fns =
    create: (req, res, next) ->
      err, n <- Users.count
      return next err if err
      (b = req.body).role = role = if n++ is 0 then \admin else \user
      #b.create_token = Signup.create-token!
      H.log "Create new user ##{n} as #{role}"
      Crud.create req, res, next, Users,
        return-fields: <[ login ]>
        #success: Signup.send-email
    read: (req, res, next) ->
      Crud.read req, res, next, Users,
        return-fields: <[ login email info quota_daily ]>
        success: (req, user, done) ->
          user.email = Crypt.decrypt user.email
          done!
    update: (req, res, next) ->
      # TODO: stop backbone sending password:''
      unless (b = req.body).password?length then delete b.password
      Crud.update req, res, next, Users, return-fields:<[ login ]>
    delete: Crud.get-invoker Users, Crud.delete, return-fields:<[ login ]>
    list: Crud.get-invoker Users, Crud.list, return-fields:<[ login info ]>
  #..verify = (req, res, next) ->
  #    err, user <- Users.findById req.id
  #    return next err if err
  #    Signup.verify req, res, next, user
