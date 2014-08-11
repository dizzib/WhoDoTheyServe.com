class ApiError extends Error
  ->
    super ...
    @name    = \ApiError
    @message = it

class AuthenticateError extends Error
  ->
    super ...
    @name    = \AuthenticateError
    @message = it

module.exports =
  ApiError         : ApiError
  AuthenticateError: AuthenticateError

  get-date-yesterday: ->
      d = new Date!
      d.setDate d.getDate! - 1
      return d
