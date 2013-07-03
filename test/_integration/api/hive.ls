Should = require \chai .should!
_      = require \underscore
H      = require \./helper

exports
  ..a = get-spec-by-key \a, '{"key":"foo","value":"bar"}'
  ..b = get-spec-by-key \b, \value-b

function get-spec-by-key key, value then
  _.extend do
    get-spec-tests get, key, value
    get-spec-tests set, key, value

function get-spec-tests op, key, value then
  "#{op.name}":
    ok : get-spec-test op, key, value, true
    bad: get-spec-test op, key, value, false

function get-spec-test op, key, value, is-ok then
  info: "hive #{op.name} #{key}"
  fn  : (done) -> op key, value, done, is-ok

function get key, expect-value, done, is-ok then
  err, res, actual-value <- H.get get-route key
  H.assert res, is-ok
  actual-value.should.equal expect-value if is-ok
  done err

function set key, value, done, is-ok then
  err, res, json-in <- H.post get-route(key), value:value
  H.assert res, is-ok
  done err

function get-route key then "hive/#{key}"
