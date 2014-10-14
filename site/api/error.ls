class ApiError extends Error

module.exports =
  Api: ApiError

  Authenticate: class AuthenticateError extends ApiError

  AuthenticateRequired: class AuthenticateRequiredError extends ApiError
