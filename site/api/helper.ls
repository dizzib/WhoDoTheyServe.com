class ApiError extends Error
  ->
    super ...
    @name    = \ApiError
    @message = it

module.exports =
  ApiError: ApiError

  get-date-yesterday: ->
      d = new Date!
      d.setDate d.getDate! - 1
      return d
