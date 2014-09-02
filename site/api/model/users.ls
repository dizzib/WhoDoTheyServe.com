M      = require \mongoose
Cons   = require \../../lib/model-constraints
Crypt  = require \../crypt
Crud   = require \../crud
P-Id   = require \./plugin-id
P-Meta = require \./plugin-meta

const AUTHTYPE-PASSWORD = \password

spec =
  login_id    : type:String, required:yes, index:{+unique} # logins._id or openauth id
  auth_type   : type:String, required:yes, enum:[AUTHTYPE-PASSWORD] ++ <[ facebook github google mock ]>
  name        : type:String, required:yes
  email       : type:String # validated below
  info        : type:String, match:Cons.url.regex
  role        : type:String, required:yes, enum:<[ admin user ]>, default:\user
  create_date : type:Date  , required:yes, default:Date.now
  quota_daily : type:Number, required:yes, default:5
  freeze_until: type:String  # allow sign-in only after this datetime

schema = new M.Schema spec
  ..plugin P-Id
  ..pre \save, (next) -> # encrypt email
    return next! unless @isModified \email
    @email = Crypt.encrypt @email
    next!
  ..pre \validate, (next) -> # validate email
    # Set self-created user's meta. This really belongs in pre-init but doesn't
    # seem to work there, so we'll leave it in pre-validate for now.
    if @isNew then @set \meta.create_user_id, @_id unless @get \meta.create_user_id
    # normal validation
    return next! unless @email
    return next! unless @isModified \email
    @invalidate \email, "Invalid email #{@email}" unless Cons.email.regex.test @email
    next!
  ..plugin P-Meta # must run after user pre-validate

module.exports = me = M.model \users, schema
  ..check-is-authtype-password = -> it.auth_type is AUTHTYPE-PASSWORD
  ..crud-fns =
    create: (req, res, next) ->
      err, n <- me.count
      return next err if err
      (b = req.body).role = role = if n++ is 0 then \admin else \user
      log "Create new user ##{n} as #{role}"
      # set defaults (req.login should be set by Logins model via routing)
      b.auth_type = AUTHTYPE-PASSWORD
      b.login_id  = req.login?_id
      Crud.create req, res, next, me,
        return-fields: <[ handle name ]>
        success: (req, user, next) ->
          user.handle = req.login?handle
          next!
    read: (req, res, next) ->
      Crud.read req, res, next, me,
        return-fields: <[ auth_type handle email info meta name quota_daily ]>
        success: (req, user, next) ->
          return next! unless user
          user.email = Crypt.decrypt user.email
          user.handle = req.login?handle
          next!
    update: Crud.get-invoker me, Crud.update, return-fields:<[ meta name ]>
    delete: Crud.get-invoker me, Crud.delete, return-fields:<[ meta name ]>
    list: Crud.get-invoker me, Crud.list, return-fields:<[ info meta name role ]>
  ..freeze = (user, cb) ->
    (d = new Date!).setSeconds d.getSeconds! + me.get-signin-bad-freeze-secs!
    me.findByIdAndUpdate user._id, freeze_until:d, cb
  ..get-signin-bad-freeze-secs = -> process.env.WDTS_USER_SIGNIN_BAD_FREEZE_SECS or 5s
  ..unfreeze = (user, cb) ->
    user.freeze_until = void
    user.save cb
