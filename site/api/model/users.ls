M     = require \mongoose
Cons  = require \../../lib/model-constraints
Crypt = require \../crypt
Crud  = require \../crud
P-Id  = require \./plugin-id

const AUTHTYPE-PASSWORD = \password

spec =
  login_id    : type:String, required:yes, index:{+unique} # logins._id or openauth id
  auth_type   : type:String, required:yes, enum:[AUTHTYPE-PASSWORD] ++ <[ facebook github google ]>
  name        : type:String, required:yes
  email       : type:String # validated below
  info        : type:String, match:Cons.url.regex
  role        : type:String, required:yes, enum:<[ admin user ]>, default:\user
  create_date : type:Date  , required:yes, default:Date.now
  quota_daily : type:Number, required:yes, default:5
  freeze_until: type:String  # allow sign-in only after this datetime
  # TODO: remove the following deprecated fields after oauth migration
  login       : type:String
  password    : type:String

schema = new M.Schema spec
  ..plugin P-Id
  ..pre \save, (next) ->     # encrypt email
    return next! unless @isModified \email
    @email = Crypt.encrypt @email
    next!
  ..pre \validate, (next) -> # validate email
    return next! unless @email
    return next! unless @isModified \email
    @invalidate \email, "Invalid email #{@email}" unless Cons.email.regex.test @email
    next!

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
        return-fields: <[ auth_type handle email info name quota_daily ]>
        success: (req, user, next) ->
          user.email = Crypt.decrypt user.email
          user.handle = req.login?handle
          next!
    update: Crud.get-invoker me, Crud.update, return-fields:<[ name ]>
    delete: Crud.get-invoker me, Crud.delete, return-fields:<[ name ]>
    list: Crud.get-invoker me, Crud.list, return-fields:<[ info name role ]>
