Should = require \chai .should!
R      = require \request
W      = require \wait.for
ST     = require \../state

r = R.defaults jar:R.jar! # clear cookie jar (signout)

module.exports = M =
  del: (path, cb) ->
    function del url, cb then r.del url, standardise cb
    W.for del, url path

  get: (path, cb) ->
    function get url, cb then r.get url, (err, response, body) ->
      cb err, { statusCode:response?statusCode, object:JSON.parse body }
    W.for get, url path

  post: (path, obj) ->
    function post url, obj, cb then r.post { url:url, json:obj }, standardise cb
    W.for post, url(path), obj

  put: (path, obj, cb) ->
    function put url, obj, cb then r.put { url:url, json:obj }, standardise cb
    W.for put, url(path), obj

  list: (route, n) ->
    res = W.for M.get, route
    M.assert res
    Should.exist list = res.object
    list.length.should.equal n

  ## assertions

  assert: (res, is-ok = true) -> (if is-ok then M.ok else M.err) res

  is-ok: -> it.statusCode is 200

  ok: -> assert-result it, 200

  err: -> assert-result it, 500

## helpers

function standardise cb then (err, resp, body) ->
  cb err, { statusCode:resp?statusCode, body:body }

function url path then "http://localhost:#{process.env.SITE_PORT}/api/#{path}"

function assert-result res, status-code-expect then
  log res.body unless res.statusCode is status-code-expect
  res.statusCode.should.equal status-code-expect
