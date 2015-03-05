Errgen = require \custom-error-generator

ApiError = Errgen \ApiError

module.exports =
  Api: ApiError

  Authenticate: Errgen \AuthenticateError, ApiError

  AuthenticateRequired: Errgen \AuthenticateRequiredError, ApiError
