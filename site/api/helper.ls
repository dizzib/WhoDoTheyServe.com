class ApiError extends Error
  ->
    super ...
    @name    = \ApiError
    @message = it

exports
  ..ApiError = ApiError

  ..get-date-yesterday = ->
      d = new Date!
      d.setDate d.getDate! - 1
      return d

  ..log = console.log
