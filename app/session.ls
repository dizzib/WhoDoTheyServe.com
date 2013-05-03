C = require \./collection

exports
  ..is-signed-in = ->
    return C.Sessions.length > 0 unless it
    return C.Sessions.models.0?id is it
  ..is-signed-in-admin = -> \admin is C.Sessions.models.0?get \role
  ..is-signed-out = -> C.Sessions.length is 0
