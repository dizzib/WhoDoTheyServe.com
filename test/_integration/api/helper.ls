Should = require \chai .should!
R      = require \request

exports
  ..del     = (path, cb)      -> exports.request.del url(path), cb
  ..get     = (path, cb)      -> exports.request.get url(path), cb
  ..post    = (path, obj, cb) -> exports.request.post { url:url(path), json:obj }, cb
  ..put     = (path, obj, cb) -> exports.request.put  { url:url(path), json:obj }, cb
  ..request = get-request!

  ..list = (done, route, n) ->
    err, res, json <- exports.get route
    return done err if err
    Should.exist json
    exports.assert res
    list = JSON.parse json
    list.length.should.equal n
    done!

  ..assert  = (res, is-ok = true) ->
    asserter = if is-ok then exports.ok else exports.err
    asserter res
  ..is-ok   = (res) -> res.statusCode is 200
  ..ok      = (res) ->
    exports.log res.body unless res.statusCode is 200
    res.statusCode.should.equal 200
  ..err     = (res) ->
    exports.log res.body unless res.statusCode is 500
    res.statusCode.should.equal 500

  ..log = console.log

function get-request then
  jar = R.jar!        # clear cookie jar (signout)
  R.defaults jar:jar

function url path then "http://localhost:4001/api/#{path}"
