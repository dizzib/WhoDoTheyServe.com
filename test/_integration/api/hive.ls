Should = require \chai .should!
_      = require \underscore
H      = require \./helper
S      = require \../spec/hive

module.exports = S.get-spec set, get #, update, remove, list, verify

function get key, is-ok, expect-value then
  H.assert res = H.get get-route key
  if is-ok then
    Should.exist res.object.value
    res.object.value.should.equal expect-value
  else
    Should.not.exist res.object.value

function set key, is-ok, value then
  H.assert (res = H.post get-route(key), value:value), is-ok

function get-route key then "hive/#{key}"
