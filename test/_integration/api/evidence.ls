_ = require \underscore
H = require \./helper
S = require \../state

exports
  ..a =
    list:
      is0: get-spec-list \a, 0
      is1: get-spec-list \a, 1
      is2: get-spec-list \a, 2
      is3: get-spec-list \a, 3
      is4: get-spec-list \a, 4
    url:
      no-http   : get-spec \a, \x, url:\foo
      no-path   : get-spec \a, \x, url:\http://
      no-domain : get-spec \a, \x, url:\http://foo
      path      : get-spec \a, 2, url:\http://foo.com
      path-qs   : get-spec \a, 3, url:\http://foo.com?bar=boo
  ..b =
    list:
      is0: get-spec-list \b, 0
      is1: get-spec-list \b, 1

export-evidences-for \a
export-evidences-for \ab
export-evidences-for \ac
export-evidences-for \b
export-evidences-for \bc
export-evidences-for \c
export-evidences-for \d
export-evidences-for \e

function export-evidences-for name then
  exports
    .."#{name}0" = get-spec name, 0
    .."#{name}1" = get-spec name, 1

function get-spec name, n, fields then
  _.extend do
    get-spec-tests create, name, n, fields
    get-spec-tests read  , name, n, fields
    get-spec-tests remove, name, n, fields

function get-spec-bad name, n, url then
  info: "create evidence #{name} bad"
  fn  : (done) -> create name, n, done, H.err, url:url

function get-spec-list name, n then
  info: "evidence list for #{name} is #{n}"
  fn  : (done) -> H.list done, get-list-route(name), n

function get-spec-tests op, name, n, fields then
  "#{op.name}":
    ok : get-spec-test op, name, n, true , fields
    bad: get-spec-test op, name, n, false, fields

function get-spec-test op, name, n, is-ok, fields then
  info: "#{op.name} evidence #{name}#{n} #{JSON.stringify(fields) ? ''}#{is-ok ? '' : ' bad'}"
  fn  : (done) -> op done, name, n, is-ok, fields

function create done, name, n, is-ok, fields then
  entity = if name.length is 1 then S.nodes[name] else H.edges[name]
  ev =
    entity_id: entity._id
    url      : get-url key = get-key(name, n)
  err, res, evi <- H.post get-route!, _.extend ev, fields
  H.assert res, is-ok
  if H.is-ok res then (H.evidences ?= {})[key] = evi
  done err

function read done, name, n, is-ok, fields then
  throw new Error 'require > 0 fields to assert' unless fields
  key = get-key name, n
  err, res, json <- H.get get-route key
  ev = JSON.parse json
  H.assert res, is-ok
  for k, v of fields then ev[k].should.equal v
  done err

function remove done, name, n, is-ok then
  key = get-key name, n
  err, res, node <- H.del get-route key
  H.assert res, is-ok
  if H.is-ok res then delete H.evidences[key]
  done err

function get-key name, n then "#{name}:#{n}"

function get-route key then
  return "evidences/#{H.evidences[key]._id}" if key
  \evidences

function get-list-route name then "evidences/for/#{S.nodes[name]._id}"

function get-url key then "http://#{key.replace(':', '')}.com"
