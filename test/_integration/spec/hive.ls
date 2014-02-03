H = require \./helper

exports.get-spec = (...args) ->
  h = H \hive, ...args

  a: h.get-spec \a, '{"key":"foo","value":"bar"}'
  b: h.get-spec \b, \value-b
