_     = require \lodash
Users = require \./users

module.exports = me =
  crud-fns:
    create: (req, res, next) ->
      me.signin req, req.user
      res.json _.pick req.user, \_id, \login, \role

    list: (req, res, next) ->
      return res.json null unless siu = req.session.signin
      err, user <- Users.findOne _id:siu.id, 'login role'
      return next err if err
      return res.json req.session = null unless user # handle corruption
      res.json user

    delete: (req, res, next) ->
      me.signout req, res, req.session.signin

  signin: (req, user) ->
    log "SignIn #{user.login} as #{user.role}"
    req.session.signin =
      id  : user._id
      role: user.role

  signout: (req, res, siu) ->
    log "SignOut #{siu.id} as #{siu.role}"
    delete req.session.signin
    res.json req.body
