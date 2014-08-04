M          = require \mongoose
Cons       = require \../../lib/model-constraints
Crypt      = require \../crypt
Crud       = require \../crud
P-Id       = require \./plugin-id

const AUTHTYPE-PASSWORD = \password

spec =
  login       : type:String, required:yes, index:{+unique}, match:Cons.login.regex
  login_id    : type:String, required:yes, index:{+unique} # logins._id or openauth id
  auth_type   : type:String, required:yes, enum:[AUTHTYPE-PASSWORD] ++ <[ facebook github google ]>
  name        : type:String, required:yes
  email       : type:String, index:{+unique} # validated below
  info        : type:String, match:Cons.url.regex
  role        : type:String, required:yes, enum:<[ admin user ]>
  create_date : type:Date  , required:yes, default:Date.now
  quota_daily : type:Number, required:yes, default:5
  freeze_until: type:String  # allow sign-in only after this datetime

schema = new M.Schema spec
  ..plugin P-Id
  # email
  ..pre \save, (next) ->
    return next! unless @isModified \email
    @email = Crypt.encrypt @email
    next!
  ..pre \validate, (next) ->
    return next! unless @isModified \email
    @invalidate \email, 'Invalid email' unless Cons.email.regex.test @email
    next!

module.exports = me = M.model \users, schema
  ..crud-fns =
    create: (req, res, next) -> # auth-type classic
      err, n <- me.count
      return next err if err
      (b = req.body).role = role = if n++ is 0 then \admin else \user
      log "Create new user ##{n} as #{role}"
      # set defaults (req.login should be set by Logins model via routing)
      b.auth_type = AUTHTYPE-PASSWORD
      b.login_id  = req.login?_id
      b.name      = req.login?login
      Crud.create req, res, next, me,
        return-fields: <[ login ]>
        #success: Signup.send-email
    read: (req, res, next) ->
      Crud.read req, res, next, me,
        return-fields: <[ login email info quota_daily ]>
        success: (req, user, done) ->
          user.email = Crypt.decrypt user.email
          done!
    update: (req, res, next) ->
      Crud.update req, res, next, me, return-fields:<[ login ]>
    delete: Crud.get-invoker me, Crud.delete, return-fields:<[ login ]>
    list: Crud.get-invoker me, Crud.list, return-fields:<[ login info role ]>
