_    = require \underscore
Cons = require \../../../lib/model-constraints
H    = require \./helper
S    = require \../state

exports
  ..ab = _.extend do
    get-spec-ab!
    is:
      eq: get-spec-ab a_is:\eq
      gt: get-spec-ab a_is:\gt
      lt: get-spec-ab a_is:\lt
    how:
      amp   : get-spec-ab how:'is founder & CEO'
      caps  : get-spec-ab how:'Honorary European Chairman'
      comma : get-spec-ab how:'is founder, CEO'
      slash : get-spec-ab how:'is founder/CEO'
      max   : get-spec-ab how:\x * 30
      max-gt: get-spec-ab how:\x * 31
      min   : get-spec-ab how:\xx
      min-lt: get-spec-ab how:\x
    year:
      from:
        null  : get-spec-ab year_from:''
        max   : get-spec-ab year_from:Cons.edge.year.max
        max-gt: get-spec-ab year_from:Cons.edge.year.max + 1
        min   : get-spec-ab year_from:Cons.edge.year.min
        min-lt: get-spec-ab year_from:Cons.edge.year.min - 1
      range:
        in : get-spec-ab year_from:2013 year_to:2013
        out: get-spec-ab year_from:2013 year_to:2012
    to-ab: get-spec-ab key-a:\a key-b:\b
    to-ba: get-spec-ab key-a:\b key-b:\a
    to-bc: get-spec-ab key-a:\b key-b:\c
  ..aa = get-spec \a, \a
  ..ac = _.extend do
    get-spec-ac!
    to-ba: get-spec-ac key-a:\b key-b:\a
  ..ba = get-spec \b, \a
  ..bc = get-spec \b, \c
  ..list =
    is0: get-spec-list 0
    is1: get-spec-list 1
    is2: get-spec-list 2
    is3: get-spec-list 3

## helpers
function get-spec-ab fields then get-spec \a, \b, fields
function get-spec-ac fields then get-spec \a, \c, fields

function get-spec key-x, key-y, fields then
  _.extend do
    get-spec-tests create, key-x, key-y, fields
    get-spec-tests read  , key-x, key-y, fields
    get-spec-tests update, key-x, key-y, fields
    get-spec-tests remove, key-x, key-y, fields

function get-spec-list n then
  info: "edge list is #{n}"
  fn  : (done) -> H.list done, get-route!, n

function get-spec-tests op, key-x, key-y, fields then
  "#{op.name}":
    ok : get-spec-test op, key-x, key-y, true , fields
    bad: get-spec-test op, key-x, key-y, false, fields

function get-spec-test op, key-x, key-y, is-ok, fields then
  info: "#{op.name} edge #{key-x}#{key-y} #{JSON.stringify(fields) ? ''}#{is-ok ? '' : ' bad'}"
  fn  : (done) -> op done, key-x, key-y, is-ok, fields

function create done, key-x, key-y, is-ok, fields then
  edge =
    a_node_id: S.nodes[key-x]._id
    b_node_id: S.nodes[key-y]._id
    a_is     : \lt
    year_from: 2000
  err, res, edge <- H.post get-route!, _.extend edge, fields
  H.assert res, is-ok
  if H.is-ok res then (H.edges ?= {})[get-edge-key key-x, key-y] = edge
  done err

function read done, key-x, key-y, is-ok, fields then
  throw new Error 'require > 0 fields to assert' unless fields
  err, res, json <- H.get get-route key-x, key-y
  edge = JSON.parse json
  H.assert res, is-ok
  for k, v of fields then edge[k].should.equal v
  done err

function update done, key-x, key-y, is-ok, fields then
  edge = _id: H.edges[get-edge-key key-x, key-y]._id
  edge.a_node_id = S.nodes[fields.key-a]._id if fields.key-a
  edge.b_node_id = S.nodes[fields.key-b]._id if fields.key-b
  err, res, edge <- H.put get-route(key-x, key-y), _.extend edge, fields
  H.assert res, is-ok
  if H.is-ok res then H.edges[get-edge-key key-x, key-y] = edge
  done err

function remove done, key-x, key-y, is-ok then
  err, res, edge <- H.del get-route key-x, key-y
  H.assert res, is-ok
  if H.is-ok res then delete H.edges[get-edge-key key-x, key-y]
  done err

function get-edge-key key-x, key-y then "#{key-x}#{key-y}"

function get-route key-x, key-y then
  return "edges/#{H.edges[get-edge-key key-x, key-y]._id}" if key-x and key-y
  \edges
