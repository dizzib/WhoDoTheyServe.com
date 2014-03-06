C = require \crypto
H = require \./helper

module.exports =
  create-token: ->
    # http://stackoverflow.com/questions/8838624/nodejs-send-email-on-registration
    C.randomBytes 16 .toString 'base64' .replace /\//g,'_' .replace /\+/g,'-'
  plugin: (schema)->
    schema.add do
      create_token: type:String, index:{+unique, +sparse}
    schema.virtual \is_verified .get -> @create_token is void
    schema.virtual \is_token_expired .get ->
      l @create_date + 1
      false
  send-email: (req, user, done) ->
    log "Send signup email to #{user.email}"
    done!
  reset-password: ->
  verify: (req, res, next, user) ->
      return next new H.ApiError 'user not found' unless user
      return next new H.ApiError 'user already verified' if user.is_verified
      return next new H.ApiError 'token has expired' if user.is-token-expired
      return next new H.ApiError 'token mismatch' unless req.params.token is user.create_token
      user.create_token = void
      err, user <- user.save!
      return next err if err
      res.send '''
        Account successfully verified!
        You should now be able to <a href='#/user-signin'>login here</a>.
      '''
