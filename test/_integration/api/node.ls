_ = require \underscore
H = require \./helper
S = require \../state

exports
  ..a = _.extend do
    get-spec \a
    name: _.extend do
      get-spec \a, name: 'Node aa'
      dup   : get-spec \a, name: 'Node AA'
      max   : get-spec \a, name: \x * 50
      max-gt: get-spec \a, name: \x * 51
      min   : get-spec \a, name: \x * 4
      min-lt: get-spec \a, name: \x * 3
      space :
        end  : get-spec \a, name: 'foo '
        start: get-spec \a, name: ' foo'
        multi: get-spec \a, name: '  multi   spaced  '
      the   :
        start: get-spec \a, name: 'The Band of England'
        has  : get-spec \a, name: 'Bank of England, The'
      you   : get-spec \a, name: 'YOU! (UK)'
      dcms  : get-spec \a, name: 'Department for Culture, Media & Sport'
      paren :
        open: get-spec \a, name: 'foo((('
  ..b = get-spec \b
  ..c = get-spec \c
  ..d = get-spec \d
  ..e = get-spec \e
  ..f = get-spec \f
  ..list =
    is0: get-spec-list 0
    is1: get-spec-list 1
    is2: get-spec-list 2
    is3: get-spec-list 3
    is4: get-spec-list 4
    is5: get-spec-list 5

## helpers
function get-spec name, fields then
  _.extend do
    get-spec-tests create, name, fields
    get-spec-tests read  , name, fields
    get-spec-tests update, name, fields
    get-spec-tests remove, name, fields

function get-spec-tests op, name, fields then
  "#{op.name}":
    ok : get-spec-test op, name, true , fields
    bad: get-spec-test op, name, false, fields

function get-spec-list n then
  info: "node list is #{n}"
  fn  : (done) -> H.list done, get-route!, n

function get-spec-test op, name, is-ok, fields then
  info: "#{op.name} node #{name} #{JSON.stringify(fields) ? ''}#{is-ok ? '' : ' bad'}"
  fn  : (done) -> op done, name, is-ok, fields

function create done, name, is-ok then
  err, res, node <- H.post get-route!, name:"Node #{name}"
  H.assert res, is-ok
  if H.is-ok res then (S.nodes ?= {})[name] = node
  done err

function read done, name, is-ok, fields then
  err, res, json <- H.get get-route name
  node = JSON.parse json
  H.assert res, is-ok
  for k, v of fields then node[k].should.equal v
  done err

function update done, name, is-ok, fields then
  node = _id: S.nodes[name]._id
  err, res, node <- H.put get-route(name), _.extend node, fields
  H.assert res, is-ok
  if H.is-ok res then S.nodes[node.name] = node
  done err

function remove done, name, is-ok then
  err, res, node <- H.del get-route name
  H.assert res, is-ok
  if H.is-ok res then delete S.nodes[name]
  done err

function get-route name then
  return "nodes/#{S.nodes[name]._id}" if name
  \nodes
